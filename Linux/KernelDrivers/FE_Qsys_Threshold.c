/** @file

This kernel driver controls an THRESHOLD block on the device

There are currently two active interfaces to control loading cofficients into the driver.

1)  The devices will load in /dev as fe_thresholdNNN and little endian files containing 32bit fixed point values can be passed into this
to update the cofficient files.  Number of coefficients are automatically computed from the length of this file.  Conversly, this entry can be read to read out the values currently loaded in the the hardware.

2)  The IOCTL interface can be used to give more control when using C programs to control the hardware




The register map for this peripherial is:

| Register Number | Register Name         |
| --------------- | --------------------- |
| 0x00            | Threshold Value       |
| 0x01            | Max Value             |
| 0x02            | Armed flag            |



The IOCTL Mapping is:

| IOCTL Number | IOCTL Name              | Description                 |
| ------------ | ----------------------- | --------------------------- |
| 0            | READ_THRESHOLD_NAME     | Gets the component name     |
| 1            | GET_THRESHOLD_THRESHOLD | Gets the threshold value    |
| 2            | SET_THRESHOLD_THRESHOLD | Sets the threshold value    |
| 3            | READ_THRESHOLD_MAX      | Read the max value          |
| 4            | SET_THRESHOLD_MAX       | Set the max value           |
| 5            | READ_THRESHOLD_ARM      | Read if the device is armed |
| 6            | SET_THRESHOLD_ARM       | Set if the device is armed  |

*/

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/io.h>
#include <linux/fs.h>
#include <linux/types.h>
#include <linux/uaccess.h>
#include <linux/init.h>
#include <linux/cdev.h>

// Define information about this kernel module
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Raymond Weber <support@flatearthinc.com>");
MODULE_DESCRIPTION("Loadable kernel module for the FE QSys THRESHOLD block");
MODULE_VERSION("1.0");


/** These are the ioctl numbers to use to communicate with the driver via those methods @todo Move these into their own file fe_threshold_ioctl.h */
#define READ_THRESHOLD_NAME 0
#define GET_THRESHOLD_THRESHOLD 1
#define SET_THRESHOLD_THRESHOLD 2
#define READ_THRESHOLD_MAX 3
#define SET_THRESHOLD_MAX 4
#define READ_THRESHOLD_ARM 5
#define SET_THRESHOLD_ARM 6


//Register memory map
#define THRESHOLD_ADDR_OFFSET 0
#define MAX_ADDR_OFFSET 1
#define ARM_ADDR_OFFSET 2




struct fixed_num
{
   int integer;
   int fraction;
   int fraction_len;
};


static struct class *cl; // Global variable for the device class
static dev_t dev_num;

// Function Prototypes
static int threshold_probe(struct platform_device *pdev);
static int threshold_remove(struct platform_device *pdev);
static ssize_t threshold_read(struct file *file, char *buffer, size_t len, loff_t *offset);
static ssize_t threshold_write(struct file *file, const char *buffer, size_t len, loff_t *offset);
static int threshold_open(struct inode *inode, struct file *file);
static int threshold_release(struct inode *inode, struct file *file);
static long threshold_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);
static ssize_t name_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t theshold_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t threshold_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count);
static ssize_t max_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t max_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count);
static ssize_t arm_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t arm_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count);


uint32_t set_fixed_num(const char *s);
int fp_to_string(char * buf, uint32_t fp28_num);

//Create the attributes that show up in /dev/class
static DEVICE_ATTR(name, 0444, name_show, NULL);
static DEVICE_ATTR(threshold, 0664, theshold_show, threshold_store);
static DEVICE_ATTR(max, 0664, max_show, max_store);
static DEVICE_ATTR(arm, 0664, arm_show, arm_store);



/** An instance of this structure will be created for every fe_threshold IP in the system
This structure holds the linux driver structure as well as a memory pointer to the hardwar and
shadow registers with the data stored on the device.
*/
struct fe_threshold_dev {
    struct cdev cdev;           ///< The driver structure containing major/minor, etc
    char *name;                 ///< This gets the name of the device when loading the driver
    void __iomem *regs;         ///< Pointer to the registers on the device
    int threshold;
    int max;
    int arm;
}; // *fe_threshold_devp;


/** Typedef of the driver structure */
typedef struct fe_threshold_dev fe_threshold_dev_t;   //Annoying but makes sonarqube not crash during the analysis in the container_of() lines

/** Id matching structure for use in driver/device matching */
static struct of_device_id fe_threshold_dt_ids[] = {
    {
        .compatible = "dev,fe-threshold"
    },
    { }
};

/** Notify the kernel about the driver matching structure information */
MODULE_DEVICE_TABLE(of, fe_threshold_dt_ids);

// Data structure with pointers to the externally important functions to be able to load the module
static struct platform_driver threshold_platform = {
    .probe = threshold_probe,
    .remove = threshold_remove,
    .driver = {
        .name = "Flat Earth THRESHOLD Driver",
        .owner = THIS_MODULE,
        .of_match_table = fe_threshold_dt_ids
    }
};

/** Structure containing pointers to the functions the driver can load */
static const struct file_operations fe_threshold_fops = {
    .owner = THIS_MODULE,
    .read = threshold_read,               ///< Read the device contents for the entry in /dev
    .write = threshold_write,             ///< Write the device contents for the entry in /dev
    .open = threshold_open,               ///< Called when the device is opened
    .release = threshold_release,         ///< Called when the device is closes
    .unlocked_ioctl = threshold_ioctl     ///< IO Control functions which are listed in fe_threshold_ioctl.h
};



/** Function called initially on the driver loads

This function is called by the kernel when the driver module is loaded and currently just calls threshold_probe()

@returns SUCCESS
*/
static int threshold_init(void)
{
    int ret_val = 0;
    pr_info("Initializing the Flat Earth THRESHOLD module\n");

    // Register our driver with the "Platform Driver" bus
    ret_val = platform_driver_register(&threshold_platform);
    if (ret_val != 0) 
    {
        pr_err("platform_driver_register returned %d\n", ret_val);
        return ret_val;
    }

    pr_info("Flat Earth THRESHOLD module successfully initialized!\n");

    return 0;
}



/** Kernel module loading for platform devices

Called by the kernel when a module is loaded which matches a device tree overlay entry.
This function does all the setup of the device driver and creates the sysfs entries.

@param pdev Pointer to a platform_device structure containing information from the overlay about the device to load
@returns SUCCESS or error code
*/
static int threshold_probe(struct platform_device *pdev)
{
    int ret_val = -EBUSY;
    struct resource *r = 0;

    char deviceName[20] = "fe_threshold";
    char deviceMinor[20];   
    int status;

    struct device *deviceObj;
    fe_threshold_dev_t * fe_threshold_devp;

    pr_info("threshold_probe enter\n");

    // Get the memory resources for this threshold device
    r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (r == NULL) 
    {
        pr_err("IORESOURCE_MEM (register space) does not exist\n");
        goto bad_exit_return;
    }
    
    // Create structure to hold device-specific information (like the registers). Make size of &pdev->dev + sizeof(struct(fe_threshold_dev)).
    fe_threshold_devp = devm_kzalloc(&pdev->dev, sizeof(fe_threshold_dev_t), GFP_KERNEL);

    // Both request and ioremap a memory region
    // This makes sure nobody else can grab this memory region
    // as well as moving it into our address space so we can actually use it
    fe_threshold_devp->regs = devm_ioremap_resource(&pdev->dev, r);
    if (IS_ERR(fe_threshold_devp->regs))
      goto bad_ioremap;
   
    // Give a pointer to the instance-specific data to the generic platform_device structure
    // so we can access this data later on (for instance, in the read and write functions)
    platform_set_drvdata(pdev, (void*)fe_threshold_devp);

    //Create a memory region to store the device name
    fe_threshold_devp->name = devm_kzalloc(&pdev->dev, 50, GFP_KERNEL);
    if (fe_threshold_devp->name == NULL)
        goto bad_mem_alloc;
    
    //Copy the name from the overlay and stick it in the created memory region
    strcpy(fe_threshold_devp->name, (char*)pdev->name);
    pr_info("%s\n", (char*)pdev->name);

    //Request a Major/Minor number for the driver
    status = alloc_chrdev_region(&dev_num, 0, 1, "fe_threshold");
    if (status != 0)
        goto bad_alloc_chrdev_region;

    //Create the device name with the information reserved above
    sprintf(deviceMinor, "%d", MAJOR(dev_num));
    strcat(deviceName, deviceMinor);
    pr_info("%s\n", deviceName);

    //Create sysfs entries
    cl = class_create(THIS_MODULE, deviceName); //"fe_threshold");
    if (cl == NULL)
        goto bad_class_create;

    //Initialize a char dev structure
    cdev_init(&fe_threshold_devp->cdev, &fe_threshold_fops);

    //Registers the char driver with the kernel
    status = cdev_add(&fe_threshold_devp->cdev, dev_num, 1);
    if (status != 0)
        goto bad_cdev_add;

    //Creates the device entries in sysfs
    deviceObj = device_create(cl, NULL, dev_num, NULL, deviceName);
    if (deviceObj == NULL)
        goto bad_device_create;

    //Put a pointer to the fe_fir_dev struct that is created into the driver object so it can be accessed uniquely from elsewhere
    dev_set_drvdata(deviceObj, fe_threshold_devp);

    //Create the sysfs entries for the driver attributes
    status = device_create_file(deviceObj, &dev_attr_threshold);
    if (status)
        goto bad_device_create_file_1;

    status = device_create_file(deviceObj, &dev_attr_max);
    if (status)
        goto bad_device_create_file_2;

    status = device_create_file(deviceObj, &dev_attr_arm);
    if (status)
        goto bad_device_create_file_3;

    status = device_create_file(deviceObj, &dev_attr_name);
    if (status)
        goto bad_device_create_file_4;

    pr_info("threshold_probe exit\n");

    return 0;

bad_device_create_file_4:
    device_remove_file(deviceObj, &dev_attr_arm);

bad_device_create_file_3:
    device_remove_file(deviceObj, &dev_attr_max);

bad_device_create_file_2:
    device_remove_file(deviceObj, &dev_attr_threshold);

bad_device_create_file_1:
    device_destroy(cl, dev_num);

bad_device_create:
    cdev_del(&fe_threshold_devp->cdev);

bad_cdev_add:
    class_destroy(cl);

bad_class_create:
    unregister_chrdev_region(dev_num, 1);

bad_alloc_chrdev_region:
bad_mem_alloc:

bad_ioremap:
   ret_val = PTR_ERR(fe_threshold_devp->regs);

bad_exit_return:
    pr_info("threshold_probe bad exit\n");
    return ret_val;
}



/** Run when the device opens to create the file structure to read and write

Beyond creating a structure which the other functions ca use to access the device, this function loads
the initial values into the shadow registers

@param inode Pointer to the instance of the hardware driver to use
@param file Pointer to the file object opened
@return SUCCESS or error code
*/
static int threshold_open(struct inode *inode, struct file *file)
{
    //Create a pointer to the driver instance
    fe_threshold_dev_t *devp;

    //Put it in the container_of structure so it can be used from anywhere
    devp = container_of(inode->i_cdev, fe_threshold_dev_t, cdev);
    file->private_data = devp;

    //Load the shadow registers with the values from the hardware registers
    devp->threshold = ioread32((u32*)devp->regs + THRESHOLD_ADDR_OFFSET);
    devp->max       = ioread32((u32*)devp->regs + MAX_ADDR_OFFSET);
    devp->arm       = ioread32((u32*)devp->regs + ARM_ADDR_OFFSET);

    return 0;
}



/** Called when the device is closed

Currently this doesn't do anything, but as it is the opposite of open I created it for future use

@param inode Instance of the driver opened
@param file Pointer to the file for this operation
@returns SUCCESS
*/
static int threshold_release(struct inode *inode, struct file *file)
{
    return 0;
}



/** Read the contents of the coefficients stucture

This function will read the contents of the coefficient memory as stored in the shadow register and return then
to the calling function as a binary array of 32 length fixed point values.  If done in the terminal window, hexdump
can be used to see the values.

@param file Pointer to the file being accessed
@param buffer Pointer to a buffer array to return the data on
@len Unused
@offset Pass-by-reference variable to hold where to start transmitting from in the array.
@returns threshold_read Number of bits sent in buffer, and will return 0 for the last transaction.
*/
static ssize_t threshold_read(struct file *file, char *buffer, size_t len, loff_t *offset)
{
    return 0;
}



/** Write the contents of the coefficients stucture

This function will write the contents of the buffer as binary values to the coefficients register.
The length variable is used to set the length of the filter itself.  After updating the shadow register, 
the values are then written to the device.  If the size of buffer is not a 4 bit multiple, the extra bytes
are ignored.

@param file Pointer to the file being written to
@param buffer Pointer to a buffer array containing the data to write
@len Number of bytes in the buffer variable
@offset Pass-by-reference variable to hold where to start transmitting from in the array.
@returns threshold_read Number of bytes written
*/
static ssize_t threshold_write(struct file *file, const char *buffer, size_t len, loff_t *offset)
{
    return 0;
}



/** Function called when the platform device driver is deleted

This function is called when the device driver is deleted.  It should cleans up the driver memory structures,
deallocate the driver addresses reserved for the driver, unallocate memory and the io mapping functions to the
hardware.  After this function, the device should be able to be added cleanly again without contention or memory
leaks.

@param platform_device Pointer to the device structure being deleted
@returns SUCCESS
*/
static int threshold_remove(struct platform_device *pdev)
{
    // Grab the instance-specific information out of the platform device
    fe_threshold_dev_t *dev = (fe_threshold_dev_t*)platform_get_drvdata(pdev);

    //device_remove_file(deviceObj, &dev_attr_numCoefs);
    //device_remove_file(deviceObj, &dev_attr_name);
    //device_remove_file(deviceObj, &dev_attr_name);

    //device_destroy(cl, dev_num);
    //class_destroy(cl);

    pr_info("threshold_remove enter\n");

    // Turn the threshold off
    //iowrite32(0x00, dev->regs);

    // Unregister the character file (remove it from /dev)
    cdev_del(&dev->cdev);

    //Tell the os that the major/minor pair is avalible again
    unregister_chrdev_region(dev_num, 2);

    //Remove the pointer to the registers so it doesn't leak
    iounmap(dev->regs);

    pr_info("threshold_remove exit\n");

    return 0;
}



// Called when the driver is removed
static void threshold_exit(void)
{
    pr_info("Flat Earth THRESHOLD module exit\n");

    // Unregister our driver from the "Platform Driver" bus
    // This will cause "threshold_remove" to be called for each connected device
    platform_driver_unregister(&threshold_platform);

    pr_info("Flat Earth THRESHOLD module successfully unregistered\n");
}



/** Function to handle the IO Control functions (ioctls)

This function handles all the IO Controls specified for the driver in fe_threshold_ioctl.h

These functions will provide deeper control of the hardware over the basic read/write functions and as such
may be slightly more hazardous to use without understanding the hardware functionality

@param filep Pointer to the file being operated on
@param cmd Interger corresponding to the function to be performed (found in fe_threshold_ioctl.h)
@param arg Argument for the ioctl operation.  This may be a value OR a pointer to a buffer depending on the function
@returns Status message OR the return value from the operation itself
*/           
static long threshold_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
{
    //Put it in the container_of structure so it can be used from anywhere
    fe_threshold_dev_t *dev = container_of(filep->private_data, fe_threshold_dev_t, cdev);

    switch (cmd)
    {
        case GET_THRESHOLD_THRESHOLD:
            return dev->threshold;

        case SET_THRESHOLD_THRESHOLD:
            dev->threshold = arg;
            iowrite32(dev->threshold, (u32*)dev->regs + THRESHOLD_ADDR_OFFSET);
            return 0;

        case READ_THRESHOLD_MAX:
            dev->max = ioread32((u32*)dev->regs + MAX_ADDR_OFFSET);
            return dev->max;

        case SET_THRESHOLD_MAX:
            dev->max = arg;
            iowrite32(dev->max, (u32*)dev->regs + MAX_ADDR_OFFSET);
            return 0;

        case READ_THRESHOLD_ARM:
            dev->arm = ioread32((u32*)dev->regs + ARM_ADDR_OFFSET);
            return dev->arm;

        case SET_THRESHOLD_ARM:
            dev->arm = arg;
            iowrite32(dev->arm, (u32*)dev->regs + ARM_ADDR_OFFSET);
            return 0;

        default:
            //Umm, the developer messed up
            return -EIO;
    }

    return 0;
}



/** Function to display the overlay name for the device in sysfs

@param dev
@param attr
@param buf charactor buffer for the sysfs return
@returns Length of the buffer

*/
static ssize_t name_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_threshold_dev_t *devp = (fe_threshold_dev_t*)dev_get_drvdata(dev);

    //Copy the name into the output buffer
    sprintf(buf, "%s\n", devp->name);

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}




static ssize_t theshold_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_threshold_dev_t *devp = (fe_threshold_dev_t*)dev_get_drvdata(dev);

    //Copy the name into the output buffer
    //sprintf(buf, "%d\n", fe_threshold_devp->threshold);
    fp_to_string(buf, devp->threshold);

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}


static ssize_t threshold_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    fe_threshold_dev_t *devp = (fe_threshold_dev_t*)dev_get_drvdata(dev);

    uint32_t tempValue = 0;

    char substring[80];
    int substring_count = 0;
    int i;

    for (i=0; i<count; i++)
    {
        //If its not a space or a comma, add the digit to the substring
        if ((buf[i] != ',') && (buf[i] != ' ') && (buf[i] != '\0') && (buf[i] != '\r') && (buf[i] != '\n'))
        {
            substring[substring_count] = buf[i];
            substring_count++;
        }
    }

    substring[substring_count] = '\0';

    //Convert the buffer to a fixed point value
    tempValue = set_fixed_num(substring);

    //Write the value into the shadow register
    devp->threshold = tempValue;

    //Write the value into the hardware
    iowrite32(devp->threshold, (u32*)devp->regs + THRESHOLD_ADDR_OFFSET);

    return count;
}


static ssize_t max_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_threshold_dev_t *devp = (fe_threshold_dev_t*)dev_get_drvdata(dev);

    devp->max = ioread32((u32*)devp->regs + MAX_ADDR_OFFSET);

    //Copy the name into the output buffer
    //sprintf(buf, "%d\n", fe_threshold_devp->gain1);
    fp_to_string(buf, devp->max);

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}


static ssize_t max_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    uint32_t tempValue = 0;
    fe_threshold_dev_t *devp = (fe_threshold_dev_t*)dev_get_drvdata(dev);

    char substring[80];
    int substring_count = 0;
    int i;

    for (i=0; i<count; i++)
    {
        //If its not a space or a comma, add the digit to the substring
        if ((buf[i] != ',') && (buf[i] != ' ') && (buf[i] != '\0') && (buf[i] != '\r') && (buf[i] != '\n'))
        {
            substring[substring_count] = buf[i];
            substring_count++;
        }
    }

    substring[substring_count] = '\0';

    //Convert the buffer to a fixed point value
    tempValue = set_fixed_num(substring);

    //Write the value into the shadow register
    devp->max = tempValue;

    //Write the value into the hardware
    iowrite32(devp->max, (u32*)devp->regs + MAX_ADDR_OFFSET);

    return count;

    return 0;
}


static ssize_t arm_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_threshold_dev_t *devp = (fe_threshold_dev_t*)dev_get_drvdata(dev);

    devp->arm = ioread32((u32*)devp->regs + ARM_ADDR_OFFSET);

    //Copy the name into the output buffer
    sprintf(buf, "%d\n", devp->arm);

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}


static ssize_t arm_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    unsigned long tempValue = 0;
    int status = 0;

    fe_threshold_dev_t *devp = (fe_threshold_dev_t*)dev_get_drvdata(dev);

    //Convert the buffer string to an integer
    status = kstrtoul(buf, 10, &tempValue);
    if (status)
        return status;

    //Write the value into the shadow register
    devp->arm = (int)tempValue;

    //Write the value into the hardware
    iowrite32(devp->arm, (u32*)devp->regs + ARM_ADDR_OFFSET);

    return count;
}




char *strcat2(char *dst, char *src)
{
    char * cp = dst;

    while (*cp)
       cp++; /* find end of dst */

    while (( *cp++ = *src++ ) != 0); /* Copy src to end of dst */

    return dst; /* return dst */
}




/** Convert a string to a fixed point number structure
@param s String containing the string to convert to 32F28 representation
@return SUCCESS

@todo This function is really ugly and could be cleaned up to make it clear what is happening....
*/
uint32_t set_fixed_num(const char *s)
{
    struct fixed_num num = {0,0,0};
    int seen_point = 0;
    int pointIndex;
    int i;
    int ii;
    int frac_comp;
    uint32_t acc = 0;
    char s2[80];
    int pointsSeen = 0;
    int charIndex = 0;

    //If no leading 0, add one (eg: .25 -> 0.25)
    if (s[0] == '.')
    {
        s2[0] = '0';
        charIndex++;
    }

    //This is a strcpy() to move the data a "const char *" to a "char *" and validate the data
    for (i=0; i<strlen(s); i++)
    {
        //Make sure the string contains an non-valid char (eg: not a number or a decimal point)
        if ((s[i] == '.') || (s[i]>='0' && s[i]<='9'))
        {          
            //Copy the data over and increment the pointer
            s2[charIndex]=s[i];
            charIndex++;
        }
        else
        {
            pr_info("Invalid char (c:%c x:%X) in number %s\n", s[i], s[i], s);
            return 0x00000000;
        }

        //Count the number of decimals in the string
        if (s[i]=='.')
            pointsSeen++;
    }

    //If multiple decimals points in the number (eg: 1.1.4)
    if (pointsSeen>1)
      pr_info("Invalid number format: %s", s);

    //Turn 1 into 1.0
/*
    if (pointsSeen == 0)
    {
        strcat2(s2,".0");
        i=i+2;
    }
*/

    //Make sure the string is terminated
    s2[i]='\0';

    //Count the fractional digits
    for (pointIndex = 0; pointIndex < strlen(s2); pointIndex++)
    {
        if (s2[pointIndex] == '.')
            break;
    }

    //String extend so that the output is accurate
    while (strlen(s2) - pointIndex<9)
        strcat2(s2, "0");

    //Truncate the string if its longer
    s2[strlen(s2) - pointIndex + 9] = '\0';

   //Covert to fixed point
   for (i = 0; i < 10; i++){
      if (s2[i] == '.') {
         seen_point = 1;
         continue;
      }
      if (!seen_point) {
         num.integer *= 10;
         num.integer += (int)(s2[i] - '0');
      }
      else
      {
         num.fraction_len++;
         num.fraction *= 10;
         num.fraction += (int)(s2[i] - '0');
      }
   }

    //Turn the fixed point conversion into binary digits
    for (ii = 0, frac_comp = 1; ii < num.fraction_len; ii++) frac_comp *= 10;
    frac_comp /= 2;

    // Get the fractional part (f28 hopefully)
    for(ii = 0;i<=36;i++)
    {
      if (num.fraction >= frac_comp) 
      {
         acc |= 0x80000001;
         num.fraction -= frac_comp;
      }
      frac_comp /= 2;

      acc = acc << 1;
    }

    //Combine the fractional part with the integer
    acc += num.integer<<28;

    return acc;
}






/** Function to convert a fp28 to a string representation
@todo doesn't handle negative numbers
*/
int fp_to_string(char * buf, uint32_t fp28_num)
{
    int buf_pos = 0;
    int i;
    int fractionPart;

    //Convert the integer part    
    buf[buf_pos] = (char)((fp28_num>>28) + '0');
    buf_pos++;

    buf[buf_pos] = '.';
    buf_pos++;

    //Mask the integer bits and dump 1 bit to make the conversion easier....
    fractionPart = (0x0FFFFFFF & fp28_num)>>1;

    for (i=0; i<8; i++)
    {        

        fractionPart *= 10;
        buf[buf_pos] = (fractionPart>>27) + '0';
        buf_pos++;
        //printf("%c",(fractionPart>>27) + '0');
        fractionPart &= 0x07FFFFFF;
    }

    buf[buf_pos] = '\0';

    return 0;
}







/** Tell the kernel what the initialization function is */
module_init(threshold_init);

/** Tell the kernel what the delete function is */
module_exit(threshold_exit);

