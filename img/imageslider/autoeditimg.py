#!/usr/bin/python2.7
import os
from PIL import Image

DATEI_WEB_GROSSE = 700

def isimg(isitimg):
	ext = os.path.splitext(isitimg)[1].lower()
	if ext == ".jpg" or ext == ".png" or ext == ".gif":
		return True
	return False

def bearbeiten(datei):
	img = Image.open(datei)
	wrel = DATEI_WEB_GROSSE / float(img.size[0])
	habs = int( float(img.size[1]) * float(wrel) )

	splt = os.path.splitext(datei)
	newfilename = splt[0] + splt[1].lower()

	img = img.resize((DATEI_WEB_GROSSE, habs), Image.ANTIALIAS)
	img.save(newfilename, quality=70, optimize=True, progressive=True)

	if newfilename != datei:
		os.rename(newfilename, datei)

def main():
	files = os.listdir('.')
	files = filter(isimg, files)
	for f in files:
		print f
		bearbeiten(f)

if __name__ == '__main__':
	main()