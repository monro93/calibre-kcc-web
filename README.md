# Docker Calibre web + KCC automatic worker
[Docker hub](https://hub.docker.com/repository/docker/monro/calibre-kcc-web/general) - [Github](https://github.com/monro93/calibre-kcc-web)

This project aims to provide a calibre-web interface (using the base image of [linuxserver](https://github.com/linuxserver/docker-calibre-web)) and a Kindle Comic converter ([kcc](https://github.com/ciromattia/kcc)) worker that will transform the comics from a folder and push them transformed to calibre.

## Running

Docker run example:
```bash
docker run -d \
  --name=calibre-web \
  -e DOCKER_MODS=linuxserver/mods:universal-calibre \
  -p 8083:8083 \
  -v ./calibre-config/config:/config \
  -v ./calibre-config/database:/database \
  -v ./kcc_worker_config.yaml:/kcc_worker_config.yaml \
  -v ./comics:/comics \
  -v ./mangas:/mangas \
  monro/calibre-kcc-web:latest
```

|Param   |Explanation   |
|---|---|
|environment DOCKER_MODS   | This is needed for now but I will try to remove it, if you add another docker mod, split them with colon(,)   |
|volume /config   |  Optional. Recommended for backups. Holds the calibre-web config  |
|volume /database   | Optional. Recommended for backups. Holds your ebooks collections. If you already have a calibre collection, mount it here  |
|volume /kcc_worker_config.yaml   |  Mandatory for running the kcc on the background. Check the [example file](kcc_worker_config_example.yaml) in this repo |
|extra volumes /comics or /mangas   | Optional, it will depend of your kcc configuration file  |

Calibre-web will be available in the following url:
[http://localhost:8083](http://localhost:8083)

## First step
On the first installation, you will be promted to setup your collection path, set the following:
```
/database
```

## Using Kcc
This project includes a job that automatically will run kcc every 5 minutes that will:
- Convert the files using kcc
- Insert the converted files in the calibre database
- Run multiple kcc parameters depending of each folder

This last step is useful to split config between comics and manga for example if for comics you would like to have color and do it for Kindle Colorsoft, you will want options similar to this: `-p KO -f EPUB --forcecolor`. But probably for mangas you would like to have other options: `-p KO -f EPUB --manga-style`.  

To define this parameters, it uses a configuration yaml file mounted at /kcc_worker_config.yaml take a look at the [example file](kcc_worker_config_example.yaml) to set up your parameteres correctly.
 
Check [kcc](https://github.com/ciromattia/kcc?tab=readme-ov-file#standalone-kcc-c2epy-usage) documentation for all the parameters that could be set up.

## Aknowlegments
This project is using the base image of [linuxsever for calibre-web](https://github.com/linuxserver/docker-calibre-web) and [kcc](https://github.com/ciromattia/kcc). I am not the owner nor contributor of any of this projects.