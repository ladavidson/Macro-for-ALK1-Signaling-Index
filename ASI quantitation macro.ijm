var path;

//open with a 3 channel TIFF file (channel1=Nuclei, channel2=pSMAD)
//press [1], [2], [3], [4] to complete image analysis
//Note: the threshold may need to be adjusted when segmenting nuclei in different samples or batches of staining before [2].
//Note: ROI of overlapping nuclei or defective regions should be removed manually under ROI manager before [3]
//Note: The mean and median of the pSMAD intensity in ROIs can be found in csv files after [4]

macro "Z projection[1]"
{
	
open("");		
dir = File.directory;

path = dir+File.separator+"DATA";
File.makeDirectory(path);
path = path+File.separator;
			
run("Z Project...", "projection=[Max Intensity]");
saveAs("Tiff", path+"MaxProjection.tif");

RawImage = getImageID();
selectImage(RawImage);
run("Duplicate...", "duplicate channels=1");
NucImage = getImageID();
selectImage(NucImage);
run("Cyan");
saveAs("Tiff", path+"NucleusImage.tif");
selectImage(NucImage);

selectImage(RawImage);
run("Duplicate...", "duplicate channels=2");
pSMADImage = getImageID();
selectImage(pSMADImage);
run("Yellow");
selectImage(RawImage);
close();
saveAs("Tiff", path+"pSMADImage.tif");
selectImage(pSMADImage);


open(path+"NucleusImage.tif");
roiManager("reset");
	
run("Median...", "radius=7");  
run("Threshold...");

}

//
// Set threshold manually
//


macro "Select and get Nuclei-pSMAD intensity [2]"
{
setThreshold(6500,65535);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Analyze Particles...", "size=45-650 circularity=0.5-1.00 show=Outlines exclude clear add");
close("Threshold");
}

//
// remove connected ROIs manually before running
//

macro "Apply nucclei ROIs at pSMAD channel [3]"

{
roiManager("Deselect");
roiManager("Save", path+"NucleusROI.zip");
run("Clear Results");
open(path+"pSMADImage.tif")
roiManager("Reset");

roiManager("Open", path+"NucleusROI.zip");

run("Set Measurements...", "area mean median redirect=None decimal=3");
roiManager("Measure");

saveAs("Results", path+"Nuc_pSMAD.csv");
run("Clear Results");
roiManager("Set Color", "cyan");
roiManager("Set Line Width", 0);
roiManager("Show All with labels");

}


macro "make a 3 pixel band and export cytoplasm and nuclear pSMAD intensity [4]"
{
run("Clear Results");
nuc=roiManager("count");
	for (i=0; i<nuc; i++)
	{
	roiManager("Select", i);
	run("Make Band...", "band=3");
	roiManager("update");
	}
roiManager("Deselect");
roiManager("Save", path+"CytoROI.zip");
roiManager("Deselect");
run("Set Measurements...", "area mean median redirect=None decimal=3");
roiManager("Measure");

saveAs("Results", path+"Cyto_pSMAD.csv");
}


macro "close all [0]"
{
run("Close All");
}

