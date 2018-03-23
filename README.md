# MDT-Powershell Bios update

I put this script together by looking online and seeing what was out there. Most scripts would just install bios update on a single model or make. This script will install bios updates on any model made by HP, Dell, or Lenovo. 

Put this script (BiosUpdate) in the application folder in your deployment folder. Name the folder the script is being put into "Bios and Firmware Upgrade", minus the quotes. 

In the same folder that the script is put into, create another folder called "Source". Open that folder and create a folder called "Dell", one for "HP", and one for "Lenovo". These are the folders where the bios updates will go.

For each model that will be updated. Create a folder in the corresponding Make. IE, for a Dell latitde E6420. In the Source folder, there should be a folder named "Dell", in that folder create a folder called "Latitude E6420". This is where you will download the exe file To update the bios. Make note of what the bios version number is. If it is A18, you will need that for the next step. Name the Bios exe to "Bios1.exe". 

Create a text file, in this file put the version name. So for A18, type A18 in the file and save it as "Version1". The script will read this file and compare the bios version in this file to the bios version that is installed to see if the bios needs to be updated. 

In the staterestore section on the TS, add a run powerschell script. Fo the powerShell Script line type "%Deployroot%\Applications\Bios and Firmware Upgrade\BiosUpdate.ps1", minus the quotes. Then create a restart just after this, so the bios will be updated during the next restart. Then click apply. 

Now for some models, before they can be updated to latest bios version, it must be updated to a intermediate version first. 

For these there is the second ps script BiosUpdate2. For these everything is the same as above. just in the folder that has the "Bios1.exe", this will now become the first bios that will be updated to. IE, the intermediate version. Then download the final version that you want the bios to be updated to and name it "Bios2.exe", a well as create a text file with the final version in it and name it "Version2".

In your TS, create another PowerShell run, use "%Deployroot%\Applications\Bios and Firmware Upgrade\BiosUpdate2.ps1", in the options add task sequence variable "Run2nd equals yes".Then click apply.

Now bios should be updated, and if, as there is for some dells, a need to run the bios update more than once. This will happen as well. 
