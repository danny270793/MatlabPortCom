%% multi_channel_resizable.m
% Connects to a two-channel serial stream (e.g. two sensors sent on the
% same line, one float value per channel per sample) and plots them live
% with an auto-resizing Y axis.
%
% Expected device output: two floating point numbers per sample, read
% sequentially, e.g.
%   1.23
%   4.56
%   1.30
%   4.80
%   ...

clear all
close all
clc

%% open the connection
port = PortCom('COM4', 115200);

%% two signals (e.g. temperature and humidity)
port.setGraphicsNumber(2);

%% let the Y axis grow/shrink with the incoming data
port.setYLimType('resizable');
port.setLimY(0, 1);

%% 1 sample every 10 ms
port.setSamplingTime(10e-3);

%% capture and live-plot 2000 samples per channel
[x, y] = port.plot(2000);

%% re-plot the captured data on a clean figure
figure
plot(x, y(1, :), 'r', x, y(2, :), 'b');
xlabel('Time (s)');
ylabel('Value');
legend('Channel 1', 'Channel 2');
title('Dual channel capture');
grid on
