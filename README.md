### Docker Calibre web + KCC automatic worker

This project aims to provide a calibre-web interface (using the base image of [linuxserver](https://github.com/linuxserver/docker-calibre-web)) and a Kindle Comic converter ([kcc](https://github.com/ciromattia/kcc/tree/a9d0c57ba65ae95fb7043080ef459a99b382b25f)) worker that will transform the comics from a folder and push them transformed to calibre.

### First step
On location of calibre database set the following path:
```
/database
```

## Using Kcc
This project includes a job that automatically will run kcc every 5 minutes that will:
- Convert the files using kcc
- Insert the converted files in the calibre database

Set the environment variable to set parameters for the kcc-c2e cli. 
You don't need to set the output folder or the input.   
You can have multiple folders with multiple kcc profiles.   
For instance, if for comics you would like to have color and do it for Kindle Colorsoft, you will want options similar to this: `-p KO -f EPUB --forcecolor`.   
But probably for mangas you would like to have other options: `-p KO -f EPUB --manga-style`.   

The final environment variable in this example would be something like this:
```
KCC_FOLDER_PARAMS="/mangas:-p KO -f EPUB --manga-style,/comics:-p KO -f EPUB --forcecolor"
```
Check [kcc](https://github.com/ciromattia/kcc?tab=readme-ov-file#standalone-kcc-c2epy-usage) documentation for all the parameters

### Aknowlegments
This project is using the base image of linuxsever for calibre-web [Repo](https://github.com/linuxserver/docker-calibre-web)