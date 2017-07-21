/** @file

This kernel driver controls an HA block on the device

There are currently two active interfaces to control loading cofficients into the driver.

1)  The devices will load in /dev as fe_HANNN and little endian files containing 32bit fixed point values can be passed into this
to update the cofficient files.  Number of coefficients are automatically computed from the length of this file.  Conversly, this entry can be read to read out the values currently loaded in the the hardware.

2)  The IOCTL interface can be used to give more control when using C programs to control the hardware





The register map for this peripherial is:

| Register Number | Register Name         |
| --------------- | --------------------- |
| 0x00            | Band1_Gain            |
| 0x01            | Band2_Gain            |
| 0x02            | Band3_Gain            |
| 0x03            | Band4_Gain            |
| 0x04            | Band5_Gain            |


The IOCTL Mapping is:

| IOCTL Number | IOCTL Name           | Description                 |
| ------------ | -------------------- | --------------------------- |
| 0            | READ_HA_NAME         | Gets the component name     |
| 1            | GET_HA_GAIN1         |                             |
| 2            | SET_HA_GAIN1         |                             |
| 3            | GET_HA_GAIN2         |                             |
| 4            | SET_HA_GAIN2         |                             |
| 5            | GET_HA_GAIN3         |                             |
| 6            | SET_HA_GAIN3         |                             |
| 7            | GET_HA_GAIN4         |                             |
| 8            | SET_HA_GAIN4         |                             |
| 9            | GET_HA_GAIN5         |                             |
| 10           | SET_HA_GAIN5         |                             |



*/

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/io.h>
#include <linux/fs.h>
#include <linux/types.h>
#include <linux/uaccess.h>
#include <linux/init.h>
#include<linux/cdev.h>

// Define information about this kernel module
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Raymond Weber <support@flatearthinc.com>");
MODULE_DESCRIPTION("Loadable kernel module for the FE QSys HA block");
MODULE_VERSION("1.0");


/** These are the ioctl numbers to use to communicate with the driver via those methods @todo Move these into their own file fe_HA_ioctl.h */
#define READ_HA_NAME 0
#define GET_HA_GAIN1 1
#define SET_HA_GAIN1 2
#define GET_HA_GAIN2 3
#define SET_HA_GAIN2 4
#define GET_HA_GAIN3 5
#define SET_HA_GAIN3 6
#define GET_HA_GAIN4 7
#define SET_HA_GAIN4 8
#define GET_HA_GAIN5 9
#define SET_HA_GAIN5 10



//Register memory map
#define BAND1_GAIN_OFFSET 0
#define BAND2_GAIN_OFFSET 1
#define BAND3_GAIN_OFFSET 2
#define BAND4_GAIN_OFFSET 3
#define BAND5_GAIN_OFFSET 4


struct fixed_num
{
   int integer;
   int fraction;
   int fraction_len;
};


static struct class *cl; // Global variable for the device class
static dev_t dev_num;

// Function Prototypes
static int HA_probe(struct platform_device *pdev);
static int HA_remove(struct platform_device *pdev);
static ssize_t HA_read(struct file *file, char *buffer, size_t len, loff_t *offset);
static ssize_t HA_write(struct file *file, const char *buffer, size_t len, loff_t *offset);
static int HA_open(struct inode *inode, struct file *file);
static int HA_release(struct inode *inode, struct file *file);
static long HA_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);
static ssize_t name_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t gain1_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t gain1_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count);
static ssize_t gain2_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t gain2_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count);
static ssize_t gain3_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t gain3_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count);
static ssize_t gain4_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t gain4_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count);
static ssize_t gain5_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t gain5_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count);


char *strcat2(char *dst, char *src);
uint32_t set_fixed_num(const char *s);
int fp_to_string(char * buf, uint32_t fp28_num);

//Create the attributes that show up in /dev/class
static DEVICE_ATTR(band1_gain, 0664, gain1_show, gain1_store);
static DEVICE_ATTR(band2_gain, 0664, gain2_show, gain2_store);
static DEVICE_ATTR(band3_gain, 0664, gain3_show, gain3_store);
static DEVICE_ATTR(band4_gain, 0664, gain4_show, gain4_store);
static DEVICE_ATTR(band5_gain, 0664, gain5_show, gain5_store);
static DEVICE_ATTR(name, 0444, name_show, NULL);


/** An instance of this structure will be created for every fe_HA IP in the system
This structure holds the linux driver structure as well as a memory pointer to the hardwar and
shadow registers with the data stored on the device.
*/
struct fe_HA_dev {
    struct cdev cdev;           ///< The driver structure containing major/minor, etc
    char *name;                 ///< This gets the name of the device when loading the driver
    void __iomem *regs;         ///< Pointer to the registers on the device
    int gain1;
    int gain2;
    int gain3;
    int gain4;
    int gain5;
};


/** Typedef of the driver structure */
typedef struct fe_HA_dev fe_HA_dev_t;   //Annoying but makes sonarqube not crash during the analysis in the container_of() lines

/** Id matching structure for use in driver/device matching */
static struct of_device_id fe_HA_dt_ids[] = {
    {
        .compatible = "dev,fe-HA"
    },
    { }
};

/** Notify the kernel about the driver matching structure information */
MODULE_DEVICE_TABLE(of, fe_HA_dt_ids);

// Data structure with pointers to the externally important functions to be able to load the module
static struct platform_driver HA_platform = {
    .probe = HA_probe,
    .remove = HA_remove,
    .driver = {
        .name = "Flat Earth HA Driver",
        .owner = THIS_MODULE,
        .of_match_table = fe_HA_dt_ids
    }
};

/** Structure containing pointers to the functions the driver can load */
static const struct file_operations fe_HA_fops = {
    .owner = THIS_MODULE,
    .read = HA_read,               ///< Read the device contents for the entry in /dev
    .write = HA_write,             ///< Write the device contents for the entry in /dev
    .open = HA_open,               ///< Called when the device is opened
    .release = HA_release,         ///< Called when the device is closes
    .unlocked_ioctl = HA_ioctl     ///< IO Control functions which are listed in fe_HA_ioctl.h
};



/** Function called initially on the driver loads

This function is called by the kernel when the driver module is loaded and currently just calls HA_probe()

@returns SUCCESS
*/
static int HA_init(void)
{
    int ret_val = 0;
    pr_info("Initializing the Flat Earth HA module\n");

    // Register our driver with the "Platform Driver" bus
    ret_val = platform_driver_register(&HA_platform);
    if (ret_val != 0) 
    {
        pr_err("platform_driver_register returned %d\n", ret_val);
        return ret_val;
    }

    pr_info("Flat Earth HA module successfully initialized!\n");

    return 0;
}



/** Kernel module loading for platform devices

Called by the kernel when a module is loaded which matches a device tree overlay entry.
This function does all the setup of the device driver and creates the sysfs entries.

@param pdev Pointer to a platform_device structure containing information from the overlay about the device to load
@returns SUCCESS or error code
*/
static int HA_probe(struct platform_device *pdev)
{
    int ret_val = -EBUSY;
    struct resource *r = 0;

    char deviceName[20] = "fe_HA";
    char deviceMinor[20];   
    int status;

    struct device *deviceObj;
    fe_HA_dev_t * fe_HA_devp;

    pr_info("HA_probe enter\n");

    // Get the memory resources for this HA device
    r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (r == NULL) 
    {
        pr_err("IORESOURCE_MEM (register space) does not exist\n");
        goto bad_exit_return;
    }
    
    // Create structure to hold device-specific information (like the registers). Make size of &pdev->dev + sizeof(struct(fe_HA_dev)).
    fe_HA_devp = devm_kzalloc(&pdev->dev, sizeof(fe_HA_dev_t), GFP_KERNEL);

    // Both request and ioremap a memory region
    // This makes sure nobody else can grab this memory region
    // as well as moving it into our address space so we can actually use it
    fe_HA_devp->regs = devm_ioremap_resource(&pdev->dev, r);
    if (IS_ERR(fe_HA_devp->regs))
      goto bad_ioremap;
   
    // Give a pointer to the instance-specific data to the generic platform_device structure
    // so we can access this data later on (for instance, in the read and write functions)
    platform_set_drvdata(pdev, (void*)fe_HA_devp);

    //Create a memory region to store the device name
    fe_HA_devp->name = devm_kzalloc(&pdev->dev, 50, GFP_KERNEL);
    if (fe_HA_devp->name == NULL)
        goto bad_mem_alloc;
    
    //Copy the name from the overlay and stick it in the created memory region
    strcpy(fe_HA_devp->name, (char*)pdev->name);
    pr_info("%s\n", (char*)pdev->name);

    //Request a Major/Minor number for the driver
    status = alloc_chrdev_region(&dev_num, 0, 1, "fe_HA");
    if (status != 0)
        goto bad_alloc_chrdev_region;

    //Create the device name with the information reserved above
    sprintf(deviceMinor, "%d", MAJOR(dev_num));
    strcat(deviceName, deviceMinor);
    pr_info("%s\n", deviceName);

    //Create sysfs entries
    cl = class_create(THIS_MODULE, deviceName); //"fe_HA");
    if (cl == NULL)
        goto bad_class_create;

    //Initialize a char dev structure
    cdev_init(&fe_HA_devp->cdev, &fe_HA_fops);

    //Registers the char driver with the kernel
    status = cdev_add(&fe_HA_devp->cdev, dev_num, 1);
    if (status != 0)
        goto bad_cdev_add;

    //Creates the device entries in sysfs
    deviceObj = device_create(cl, NULL, dev_num, NULL, deviceName);
    if (deviceObj == NULL)
        goto bad_device_create;

    //Put a pointer to the fe_fir_dev struct that is created into the driver object so it can be accessed uniquely from elsewhere
    dev_set_drvdata(deviceObj, fe_HA_devp);

    //Create the sysfs entries for the driver attributes
    status = device_create_file(deviceObj, &dev_attr_band1_gain);
    if (status)
        goto bad_device_create_file_1;

    status = device_create_file(deviceObj, &dev_attr_band2_gain);
    if (status)
        goto bad_device_create_file_2;

    status = device_create_file(deviceObj, &dev_attr_band3_gain);
    if (status)
        goto bad_device_create_file_3;

    status = device_create_file(deviceObj, &dev_attr_band4_gain);
    if (status)
        goto bad_device_create_file_4;

    status = device_create_file(deviceObj, &dev_attr_band5_gain);
    if (status)
        goto bad_device_create_file_5;

    status = device_create_file(deviceObj, &dev_attr_name);
    if (status)
        goto bad_device_create_file_6;

    pr_info("HA_probe exit\n");

    return 0;


bad_device_create_file_6:
    device_remove_file(deviceObj, &dev_attr_band5_gain);

bad_device_create_file_5:
    device_remove_file(deviceObj, &dev_attr_band4_gain);

bad_device_create_file_4:
    device_remove_file(deviceObj, &dev_attr_band3_gain);

bad_device_create_file_3:
    device_remove_file(deviceObj, &dev_attr_band2_gain);

bad_device_create_file_2:
    device_remove_file(deviceObj, &dev_attr_band1_gain);

bad_device_create_file_1:
    device_destroy(cl, dev_num);

bad_device_create:
    cdev_del(&fe_HA_devp->cdev);

bad_cdev_add:
    class_destroy(cl);

bad_class_create:
    unregister_chrdev_region(dev_num, 1);

bad_alloc_chrdev_region:
bad_mem_alloc:

bad_ioremap:
   ret_val = PTR_ERR(fe_HA_devp->regs);

bad_exit_return:
    pr_info("HA_probe bad exit\n");
    return ret_val;
}



/** Run when the device opens to create the file structure to read and write

Beyond creating a structure which the other functions ca use to access the device, this function loads
the initial values into the shadow registers

@param inode Pointer to the instance of the hardware driver to use
@param file Pointer to the file object opened
@return SUCCESS or error code
*/
static int HA_open(struct inode *inode, struct file *file)
{
    //Create a pointer to the driver instance
    fe_HA_dev_t *devp;

    //Put it in the container_of structure so it can be used from anywhere
    devp = container_of(inode->i_cdev, fe_HA_dev_t, cdev);
    file->private_data = devp;

    //Load the shadow registers with the values from the hardware registers
    devp->gain1       = ioread32((u32*)devp->regs + BAND1_GAIN_OFFSET);
    devp->gain2       = ioread32((u32*)devp->regs + BAND2_GAIN_OFFSET);
    devp->gain3       = ioread32((u32*)devp->regs + BAND3_GAIN_OFFSET);
    devp->gain4       = ioread32((u32*)devp->regs + BAND4_GAIN_OFFSET);
    devp->gain5       = ioread32((u32*)devp->regs + BAND5_GAIN_OFFSET);

    return 0;
}



/** Called when the device is closed

Currently this doesn't do anything, but as it is the opposite of open I created it for future use

@param inode Instance of the driver opened
@param file Pointer to the file for this operation
@returns SUCCESS
*/
static int HA_release(struct inode *inode, struct file *file)
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
@returns HA_read Number of bits sent in buffer, and will return 0 for the last transaction.
*/
static ssize_t HA_read(struct file *file, char *buffer, size_t len, loff_t *offset)
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
@returns HA_read Number of bytes written
*/
static ssize_t HA_write(struct file *file, const char *buffer, size_t len, loff_t *offset)
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
static int HA_remove(struct platform_device *pdev)
{
    // Grab the instance-specific information out of the platform device
    fe_HA_dev_t *dev = (fe_HA_dev_t*)platform_get_drvdata(pdev);

    //device_remove_file(deviceObj, &dev_attr_numCoefs);
    //device_remove_file(deviceObj, &dev_attr_name);
    //device_remove_file(deviceObj, &dev_attr_name);

    //device_destroy(cl, dev_num);
    //class_destroy(cl);


    pr_info("HA_remove enter\n");

    // Turn the HA off
    //iowrite32(0x00, dev->regs);

    // Unregister the character file (remove it from /dev)
    cdev_del(&dev->cdev);

    //Tell the os that the major/minor pair is avalible again
    unregister_chrdev_region(dev_num, 2);

    //Remove the pointer to the registers so it doesn't leak
    iounmap(dev->regs);

    pr_info("HA_remove exit\n");

    return 0;
}



// Called when the driver is removed
static void HA_exit(void)
{
    pr_info("Flat Earth HA module exit\n");

    // Unregister our driver from the "Platform Driver" bus
    // This will cause "HA_remove" to be called for each connected device
    platform_driver_unregister(&HA_platform);

    pr_info("Flat Earth HA module successfully unregistered\n");
}



/** Function to handle the IO Control functions (ioctls)

This function handles all the IO Controls specified for the driver in fe_HA_ioctl.h

These functions will provide deeper control of the hardware over the basic read/write functions and as such
may be slightly more hazardous to use without understanding the hardware functionality

@param filep Pointer to the file being operated on
@param cmd Interger corresponding to the function to be performed (found in fe_HA_ioctl.h)
@param arg Argument for the ioctl operation.  This may be a value OR a pointer to a buffer depending on the function
@returns Status message OR the return value from the operation itself
*/           
static long HA_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
{
    //Put it in the container_of structure so it can be used from anywhere
    fe_HA_dev_t *dev = container_of(filep->private_data, fe_HA_dev_t, cdev);

    switch (cmd)
    {
        case GET_HA_GAIN1:
            return dev->gain1;

        case SET_HA_GAIN1:
            dev->gain1 = arg;
            iowrite32(dev->gain1, (u32*)dev->regs + BAND1_GAIN_OFFSET);
            return 0;

        case GET_HA_GAIN2:
            return dev->gain2;

        case SET_HA_GAIN2:
            dev->gain2 = arg;
            iowrite32(dev->gain2, (u32*)dev->regs + BAND2_GAIN_OFFSET);
            return 0;

        case GET_HA_GAIN3:
            return dev->gain3;

        case SET_HA_GAIN3:
            dev->gain3 = arg;
            iowrite32(dev->gain3, (u32*)dev->regs + BAND3_GAIN_OFFSET);
            return 0;

        case GET_HA_GAIN4:
            return dev->gain4;

        case SET_HA_GAIN4:
            dev->gain4 = arg;
            iowrite32(dev->gain4, (u32*)dev->regs + BAND4_GAIN_OFFSET);
            return 0;

        case GET_HA_GAIN5:
            return dev->gain5;

        case SET_HA_GAIN5:
            dev->gain5 = arg;
            iowrite32(dev->gain5, (u32*)dev->regs + BAND5_GAIN_OFFSET);
            return 0;

        default:
            //Umm, the developer messed up
            return -EIO;
    }

    return 0;
}



/** Function to display the overlay name for the device in sysfs

@todo Better understand the inputs

@param dev
@param attr
@param buf charactor buffer for the sysfs return
@returns Length of the buffer
*/
static ssize_t name_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

    //Copy the name into the output buffer
    sprintf(buf, "%s\n", devp->name);

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}















static ssize_t gain1_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

    //Copy the name into the output buffer
    //sprintf(buf, "%d\n", fe_HA_devp->threshold);
    fp_to_string(buf, devp->gain1);

    strcat2(buf, "\n");

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}

static ssize_t gain1_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    uint32_t tempValue = 0;

    char substring[80];
    int substring_count = 0;
    int i;

    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

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
    devp->gain1 = tempValue;

    //Write the value into the hardware
    iowrite32(devp->gain1, (u32*)devp->regs + BAND1_GAIN_OFFSET);

    return count;
}

static ssize_t gain2_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

    //Copy the name into the output buffer
    //sprintf(buf, "%d\n", fe_HA_devp->gain1);
    fp_to_string(buf, devp->gain2);

    strcat2(buf, "\n");

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}

static ssize_t gain2_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    uint32_t tempValue = 0;

    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

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
    devp->gain2 = tempValue;

    //Write the value into the hardware
    iowrite32(devp->gain2, (u32*)devp->regs + BAND2_GAIN_OFFSET);

    return count;
}


static ssize_t gain3_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

    //Copy the name into the output buffer
    //sprintf(buf, "%d\n", fe_HA_devp->gain2);

    fp_to_string(buf, devp->gain3);

    strcat2(buf, "\n");

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}

static ssize_t gain3_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    uint32_t tempValue = 0;

    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

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
    devp->gain3 = tempValue;

    //Write the value into the hardware
    iowrite32(devp->gain3, (u32*)devp->regs + BAND3_GAIN_OFFSET);


    return count;
}

static ssize_t gain4_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

    //Copy the name into the output buffer
    //sprintf(buf, "%d\n", fe_HA_devp->exponent);

    fp_to_string(buf, devp->gain4);
    
    strcat2(buf, "\n");

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}


static ssize_t gain4_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    uint32_t tempValue = 0;

    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

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
    devp->gain4 = tempValue;

    //Write the value into the hardware
    iowrite32(devp->gain4, (u32*)devp->regs + BAND4_GAIN_OFFSET);

    return count;
}


static ssize_t gain5_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

    //Copy the name into the output buffer
    //sprintf(buf, "%d\n", fe_HA_devp->exponent);

    fp_to_string(buf, devp->gain5);
    
    strcat2(buf, "\n");

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}


static ssize_t gain5_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    uint32_t tempValue = 0;

    fe_HA_dev_t *devp = (fe_HA_dev_t*)dev_get_drvdata(dev);

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
    devp->gain5 = tempValue;

    //Write the value into the hardware
    iowrite32(devp->gain5, (u32*)devp->regs + BAND5_GAIN_OFFSET);

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
@param s String containing the string to convert to 32F16 representation
@return SUCCESS

@todo This function is really ugly and could be cleaned up to make it clear what is happening....
*/
uint32_t set_fixed_num(const char *s)
{
    struct fixed_num num = {0, 0, 0};
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
    for (ii = 0; i<=36; i++){
      if (num.fraction >= frac_comp) {
         acc |= 0x00000001;
         num.fraction -= frac_comp;
      }
      frac_comp /= 2;

      acc = acc << 1;
    }

    acc = acc >> 12;

    //Combine the fractional part with the integer
    acc += num.integer<<16;

    return acc;
}






/** Function to convert a fp16 to a string representation
@todo doesn't handle negative numbers
*/
int fp_to_string(char * buf, uint32_t fp28_num)
{
    int buf_pos = 0;
    int i;
    int fractionPart;
    //int isNegative = 0;
    int intPart = 1;
    int i16 = 0;

    if (fp28_num & 0x80000000)
    {
        fp28_num *= -1;

        buf[buf_pos]='-';
        buf_pos++;
    }

    //Convert the integer part    
    i16 = (fp28_num>>16);
    while ( (i16/intPart) > 9)
    {
        intPart *= 10;
    }

    while (intPart>0)
    {
        buf[buf_pos] = (char)((i16/intPart) + '0');
        buf_pos++;

        i16 = i16 % intPart;
        intPart = intPart/10;
    }

    //buf[buf_pos] = (char)((fp28_num>>16) + '0');
    //buf_pos++;

    buf[buf_pos] = '.';
    buf_pos++;

    //Mask the integer bits and dump 1 bit to make the conversion easier....
    fractionPart = (0x0000FFFF & fp28_num)>>1;  // 32F27 so that 0-9 can fit in the high 5 bits)

    for (i=0; i<8; i++)
    {
        fractionPart *= 10;
        buf[buf_pos] = (fractionPart>>15) + '0';
        buf_pos++;
        fractionPart &= 0x00007FFF;
    }

    buf[buf_pos] = '\0';

    return 0;
}









/** Tell the kernel what the initialization function is */
module_init(HA_init);

/** Tell the kernel what the delete function is */
module_exit(HA_exit);

