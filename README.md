# Hugo Blog

This is my blog: [https://www.evzpav.com/](https://www.evzpav.com/)

Run Hugo development server. To be used to write posts:
```bash
make run-local
```
Blog will be running on [http://localhost:1313](http://localhost:1313).

Build static files, add files to Nginx docker image and serve via Nginx:
```bash
make run-docker
```
Blog will be running on [http://localhost:1414](http://localhost:1414).