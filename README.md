LiveSnooker
==================
Front-end web components for https://github.com/RedBulli/LiveSnooker-Server

Dependencies
------------
* Node >=4.2.2 

Installation
------------
```
npm install
```

Serve files in development
------------
Copy environments/sample.env to environments/development.env and modify values (defaults might also work for you). Then run:
```
./grunt.sh
```
Browse to localhost:9000

Building to production
------------
Create environments/dist.env and then build files:
```
./grunt.sh build:dist
```
