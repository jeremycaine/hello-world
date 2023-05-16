# 1. Build and Run a Local Hello World application
To introduce the concepts and foundations within OpenShift we are going to start with some simpler source and build files. 

## 1.1 Simple Application
Start by cloning the repo and using the files needed in this first step. In a terminal window:
```
git clone https://github.com/jeremycaine/hello-world
cd hello-world
cp ./src/server-v1.js ./server.js
npm install
npm run start
```

The output will show the build description infromation and the process id the app is running as.
```

> hello-world@1.0.0 start /Users/jeremycaine/Documents/code/github.com/jeremycaine/hello-world
> node server.js

Build:
-version: v1
-description: Simple server; No Signal intercept

Process ID: 8891
Server version is running on http://localhost:3000
```
From another terminal check the application is running 
```
$ curl http://localhost:3000
Hello World ! (version v1)
```
and observe the log output in the original terminal window
```
...
Server version is running on http://localhost:3000
hello-world called
...
```

## 1.2 Add Signal Handling
Next we want to add signal handling to the NodeJS application so it can respond to graceful and unexpected termination signals.

```
cp ./src/server-v2.js ./server.js
npm install
npm run start
```
Output has changed to 
```

> hello-world@1.0.0 start /Users/jeremycaine/Documents/code/github.com/jeremycaine/hello-world
> node server.js

Build:
-version: v2
-description: Simple server; With Signal intercept

Server version is running on http://localhost:3000
```
And if you call `curl http://localhost:3000` you see the message `Hello World ! (version v2)`.

But now, the app will respond to a kill action. 

Keystroke Ctrl+C is interrupt triggering SIGINT.
```
...
Process ID: 8891
Server version is running on http://localhost:3000
hello-world called
^CSIGINT signal received
HTTP server closed
hello-world app shutting down
```

Or if you find the process id (PID) and issue a Kill (SIGTERM) command e.g. `kill 9098`
```
Process ID: 9098
Server version is running on http://localhost:3000
SIGTERM signal received
HTTP server closed
hello-world app shutting down
```


| Previous        | Next          |
| ------------- | -------------|
|[README](../README.md) | [2. Local Podman Build and Run](2-local-podman-build-and-run.md)|
