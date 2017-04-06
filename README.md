# save2pdf_embedfonts
Matlab save2pdf modified to have embedded fonts

ghostscript.m function comes from export_fig
save2pdf_embed.m is the function to use
	it is adapted from save2pdf.m, besides what was done previously by save2pdf
	it saves the image in a pdf format with a random temporary name, unique inside the folder in use (the folder where the final file will be saved)
	it resaves the image and embeds all the fonts (uses ghostscript for this job)
		(atention should be given to 3D images -> the 'painters' renderer is being used to force the image to be saved in vectorial format, it might generate issues with 3D images)

- Requirements:
	Ghostscript must be installed (tested on the 64bit version)
	