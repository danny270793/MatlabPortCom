%% basic_read.m
% Connects to a single-channel serial stream and plots 1000 samples
% with a fixed Y axis.
%
% Expected device output: one floating point number per line, e.g.
%   3.14
%   3.18
%   3.21
%   ...

clear all
close all
clc

%% open the connection
port = PortCom('COM3', 9600);

%% one signal only
port.setGraphicsNumber(1);

%% fixed Y axis between 0 and 5 volts
port.setYLimType('inmobile');
port.setLimY(0, 5);

%% 1 sample every 20 ms
port.setSamplingTime(20e-3);

%% capture and live-plot 1000 samples
[x, y] = port.plot(1000);

%% re-plot the captured data on a clean figure
figure
plot(x, y, 'r');
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Single channel capture');
grid on
