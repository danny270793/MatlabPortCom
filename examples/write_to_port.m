%% write_to_port.m
% Sends a command to the connected device over the serial port.
% Useful for toggling an LED, requesting a mode change, etc.

clear all
close all
clc

%% open the connection
port = PortCom('COM3', 9600);

%% send a command to the device
port.write('1');
