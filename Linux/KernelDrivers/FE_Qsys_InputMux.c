/** @file

This is a linux module driver to control the input mux selection.

To use it in the terminal commands can be "echo 1 > /dev/fe_imux"'ed into the device
and read back out using cat.

In a program, the device can be opened, and read and written using standard file descriptors.

@verbatim
The inputs are:
0 - All channels muted  (0x00)
1 - Line_In selected    (0x01)
2 - Microphone selected (0x02)
@endverbatim
*/


#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/io.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/types.h>
#include <linux/uaccess.h>

// Define information about this kernel module
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Raymond Weber <support@flatearthinc.com>");
MODULE_DESCRIPTION("Loadable kernel module for the FE QSys input Mux block");
MODULE_VERSION("1.0");

// Function Prototypes
static int mux_probe(struct platform_device *pdev);
static int mux_remove(struct platform_device *pdev);
static ssize_t mux_read(struct file *file, char *buffer, size_t len, loff_t *offset);
static ssize_t mux_write(struct file *file, const char *buffer, size_t len, loff_t *offset);
static ssize_t input_show(struct device *dev, struct device_attribute *attr, char *buf);
static ssize_t input_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count);
static ssize_t name_show(struct device *dev, struct device_attribute *attr, char *buf);

//Register mapping
#define input_MODE_ADDR 0

static struct class *cl; // Global variable for the device class
static dev_t dev_num;


// An instance of this structure will be created for every fe_mux IP in the system
struct fe_mux_dev {
    struct cdev cdev;           ///< The driver structure containing major/minor, etc
    void __iomem *regs;         ///< A pointer to the registers on the device itself
    int mux_value;              ///< Shadow register for the mux value
    char *name;                 ///< Will hold the device name and memory address for identification of the device
};


static DEVICE_ATTR(input, 0664, input_show, input_store);        // Create a device attribute to be able to set in /sys/class
static DEVICE_ATTR(name, 0444, name_show, NULL);

typedef struct fe_mux_dev fe_mux_dev_t;   //Annoying but makes sonarqube not crash during the analysis in the container_of() lines

// Specify what dts driver names this driver will load for
static struct of_device_id fe_mux_dt_ids[] = {
    {
        .compatible = "dev,fe-input-mux"
    },
    { }
};

// Let the kernel know about the dts listings that this should load for
MODULE_DEVICE_TABLE(of, fe_mux_dt_ids);

// Data structure with pointers to the externally important functions to be able to load the module
static struct platform_driver mux_platform = {
    .probe = mux_probe,
    .remove = mux_remove,
    .driver = {
        .name = "Flat Earth input Mux Driver",
        .owner = THIS_MODULE,
        .of_match_table = fe_mux_dt_ids
    }
};

// Data structure with the functions that the module can do after its been loaded
static const struct file_operations fe_mux_fops = {
    .owner = THIS_MODULE,
    .read = mux_read,
    .write = mux_write
};

// Called when the driver is installed
static int mux_init(void)
{
    int ret_val = 0;
    pr_info("Initializing the Flat Earth input Mux module\n");

    // Register our driver with the "Platform Driver" bus
    ret_val = platform_driver_register(&mux_platform);
    if (ret_val != 0) {
        pr_err("platform_driver_register returned %d\n", ret_val);
        return ret_val;
    }

    pr_info("Flat Earth input Mux module successfully initialized!\n");

    return 0;
}

// Called whenever the kernel finds a new device that our driver can handle
// (In our case, this should only get called for the one instantiation of the fe mux module)
static int mux_probe(struct platform_device *pdev)
{
    int ret_val = -EBUSY;
    struct resource *r = 0;

    char deviceName[20] = "fe_mux";
    char deviceMinor[20];   
    int status;

    fe_mux_dev_t * fe_mux_devp;
    struct device *deviceObj;

    pr_info("mux_probe enter\n");

    // Get the memory resources for this mux device
    r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (r == NULL) 
    {
        pr_err("IORESOURCE_MEM (register space) does not exist\n");
        goto bad_exit_return;
    }
    
    // Create structure to hold device-specific information (like the registers). Make size of &pdev->dev + sizeof(struct(fe_fir_dev)).
    fe_mux_devp = devm_kzalloc(&pdev->dev, sizeof(fe_mux_dev_t), GFP_KERNEL);

    // Both request and ioremap a memory region
    // This makes sure nobody else can grab this memory region
    // as well as moving it into our address space so we can actually use it
    fe_mux_devp->regs = devm_ioremap_resource(&pdev->dev, r);
    if (IS_ERR(fe_mux_devp->regs))
      goto bad_ioremap;
   
    // Turn the mux on (access the 0th register in the fe mux module)
    fe_mux_devp->mux_value = 0x0001;
    iowrite32(fe_mux_devp->mux_value, (u32*)fe_mux_devp->regs + input_MODE_ADDR);

    // Give a pointer to the instance-specific data to the generic platform_device structure
    // so we can access this data later on (for instance, in the read and write functions)
    platform_set_drvdata(pdev, (void*)fe_mux_devp);

    //Create a memory region to store the device name
    fe_mux_devp->name = devm_kzalloc(&pdev->dev, 50, GFP_KERNEL);
    if (fe_mux_devp->name == NULL)
        goto bad_mem_alloc;
    
    //Copy the name from the overlay and stick it in the created memory region
    strcpy(fe_mux_devp->name, (char*)pdev->name);
    pr_info("%s\n", (char*)pdev->name);

    //Request a Major/Minor number for the driver
    status = alloc_chrdev_region(&dev_num, 0, 1, "fe_mux");
    if (status != 0)
        goto bad_alloc_chrdev_region;

    //Create the device name with the information reserved above
    sprintf(deviceMinor, "%d", MAJOR(dev_num));
    strcat(deviceName, deviceMinor);
    pr_info("%s\n", deviceName);

    //Create sysfs entries
    cl = class_create(THIS_MODULE, deviceName);
    if (cl == NULL)
        goto bad_class_create;

    //Initialize a char dev structure
    cdev_init(&fe_mux_devp->cdev, &fe_mux_fops);

    //Registers the char driver with the kernel
    status = cdev_add(&fe_mux_devp->cdev, dev_num, 1);
    if (status != 0)
        goto bad_cdev_add;

    //Creates the device entries in sysfs
    deviceObj = device_create(cl, NULL, dev_num, NULL, deviceName);
    if (deviceObj == NULL)
        goto bad_device_create;

    //Put a pointer to the fe_mux_dev struct that is created into the driver object so it can be accessed uniquely from elsewhere
    dev_set_drvdata(deviceObj, fe_mux_devp);

    //Create the class attribute files
    status = device_create_file(deviceObj, &dev_attr_input);
    if (status)
        goto bad_device_create_file_1;

    //Create the class attribute files
    status = device_create_file(deviceObj, &dev_attr_name);
    if (status)
        goto bad_device_create_file_2;


    pr_info("mux_probe exit\n");

    return 0;



bad_device_create_file_2:
    device_remove_file(deviceObj, &dev_attr_input);
bad_device_create_file_1:
    device_destroy(cl, dev_num);
bad_device_create:
    cdev_del(&fe_mux_devp->cdev);
bad_cdev_add:
    class_destroy(cl);
bad_class_create:
    unregister_chrdev_region(dev_num, 1);
bad_alloc_chrdev_region:
bad_mem_alloc:
bad_ioremap:
   ret_val = PTR_ERR(fe_mux_devp->regs);
bad_exit_return:
    pr_info("fir_probe bad exit\n");
    return ret_val;


/*
bad_ioremap:
   ret_val = PTR_ERR(dev->regs);

bad_exit_return:
    pr_info("mux_probe bad exit :(\n");
    return ret_val;
*/
}

// This function gets called whenever a read operation occurs on one of the character files
static ssize_t mux_read(struct file *file, char *buffer, size_t len, loff_t *offset)
{
    int success = 0;

    fe_mux_dev_t *dev = container_of(file->private_data, fe_mux_dev_t, cdev);

    // Give the user the current mux value
    success = copy_to_user(buffer, &dev->mux_value, sizeof(dev->mux_value));

    // If we failed to copy the value to userspace, display an error message
    if (success != 0) {
        pr_info("Failed to return current mux value to userspace\n");
        return -EFAULT; // Bad address error value. It's likely that "buffer" doesn't point to a good address
    }

    return 1; //1 indicates that 1 char is to be sent to the console // "0" indicates End of File, aka, it tells the user process to stop reading
}

// This function gets called whenever a write operation occurs on one of the character files
static ssize_t mux_write(struct file *file, const char *buffer, size_t len, loff_t *offset)
{
    int success = 0;

    fe_mux_dev_t *dev = container_of(file->private_data, fe_mux_dev_t, cdev);

    // Get the new mux value (this is just the muxst byte of the given data)
    success = copy_from_user(&dev->mux_value, buffer, sizeof(dev->mux_value));

    // If we failed to copy the value from userspace, display an error message
    if (success != 0) {
        pr_info("Failed to read mux value from userspace\n");
        return -EFAULT; // Bad address error value. It's likely that "buffer" doesn't point to a good address
    } else {
        // We read the data correctly, so update the mux
        iowrite32(dev->mux_value, dev->regs);
    }

    return len;
}

// Gets called whenever a device this driver handles is removed.
// This will also get called for each device being handled when 
// our driver gets removed from the system (using the rmmod command).
static int mux_remove(struct platform_device *pdev)
{
    // Grab the instance-specific information out of the platform device
    fe_mux_dev_t *dev = (fe_mux_dev_t*)platform_get_drvdata(pdev);

    pr_info("mux_remove enter\n");

    cdev_del(&dev->cdev);
    class_destroy(cl);
    unregister_chrdev_region(dev_num, 1);

    pr_info("mux_remove exit\n");

    return 0;
}

// Called when the driver is removed
static void mux_exit(void)
{
    pr_info("Flat Earth input Mux module exit\n");

    // Unregister our driver from the "Platform Driver" bus
    // This will cause "mux_remove" to be called for each connected device
    platform_driver_unregister(&mux_platform);

    pr_info("Flat Earth input Mux module successfully unregistered\n");
}


/** Function to read the input mux setting

Valid inputs are "mute","input1","input2", "both", or "invalid"

@param dev Pointer to the instance of the device driver
@param attr ?
@param buf input of this command
@returns Length of the input buffer
*/
static ssize_t input_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_mux_dev_t *devp = (fe_mux_dev_t*)dev_get_drvdata(dev);

    int muxValue = devp->mux_value;

    if (muxValue == 0)
    {
        strcpy(buf, "mute\n");
    }
    else if (muxValue == 1)
    {
        strcpy(buf, "input1\n");
    }
    else if (muxValue == 2)
    {
        strcpy(buf, "input2\n");
    }
    else
    {
        pr_info("Invalid: %d\n", muxValue);
        strcpy(buf, "invalid\n");
    }

    return strlen(buf);
}



/** Function to store the input mux setting

Funtion to be able to store a value in the input mux in the sysfs class directory
Valid modes are are ["mute" or "0"], ["input1" or "1"], ["input2" or "2"], and ["both" or "3"]

@param dev Pointer to the instance of the device driver
@param attr ?
@param buf Input buffer with the inputted data from the terminal/write command
@param count Length of the input buffer
@returns Length of the input buffer
*/
static ssize_t input_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
    fe_mux_dev_t *devp = (fe_mux_dev_t*)dev_get_drvdata(dev);

    pr_info("%s\n", buf);

    //if (strcmp(buf, "mute") || strcmp(buf, "0"))
    if (buf[0] == '0')
    {
        devp->mux_value = 0;
    }
    //else if (strcmp(buf, "input1") || strcmp(buf, "1"))
    else if (buf[0] == '1')
    {
        devp->mux_value = 1;
    }
    //else if (strcmp(buf, "input2") || strcmp(buf, "2"))
    else if (buf[0] == '2')
    {
        devp->mux_value = 2;
    }
    else
    {
        pr_info("Invalid: %s\n", buf);
        pr_info("%c %c\n", buf[0], buf[1]);
        pr_info("Invalid Mode\n");
    }

    //Write the value into the hardware
    iowrite32(devp->mux_value, (u32*)devp->regs + input_MODE_ADDR);

    return count;
}


/** Function to display the overlay name for the device in sysfs

@param dev
@param attr
@param buf charactor buffer for the sysfs return
@returns Length of the buffer
*/
static ssize_t name_show(struct device *dev, struct device_attribute *attr, char *buf)
{
    fe_mux_dev_t *devp = (fe_mux_dev_t*)dev_get_drvdata(dev);

    //Copy the name into the output buffer
    sprintf(buf, "%s\n", devp->name);

    //Return the length of the buffer so it will print in the console
    return strlen(buf);
}





// Tell the kernel which functions are the initialization and exit functions
module_init(mux_init);
module_exit(mux_exit);

