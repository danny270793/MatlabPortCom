# PortCom

Librari to read and plot data from serial port using Matlab

## Ussage

```matlab
%% clear all
clear all
close all
clc

%% create connection
port=PortCom('COM4',9600);

%% configure plot ui
port.setYLimType('resizable')
port.setLimY(0,20);

%% define how many lines will be ploted
port.setGraphicsNumber(2);

%% plot a number of measures
[x,y]=port.plot(5000);
```

## Follow me

- [Youtube](https://www.youtube.com/channel/UC5MAQWU2s2VESTXaUo-ysgg)
- [Github](https://www.github.com/danny270793/)
- [LinkedIn](https://www.linkedin.com/in/danny270793)

## LICENSE

Licensed under the [MIT](license.md) License

## Version

MatlabPortCom version 1.0.0

Last update 10/03/2023
