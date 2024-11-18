You can compile and use the assembler for the multicycle processor in the NIOS II Cygwin console, which gives you a Linux shell environment:
1.	Open Start->All Programs->Altera 11.1...->Nios II EDS...->NIOS II Command Shell
2.  You can reach your W:\ directory with 
		> cd /cygdrive/w/
	and other Windows paths in similar fashion
3.	Go to the path holding the asm.cpp source and type
		> make
4. You can now assemble files by calling
		> ./asm YOURCODE.s
5. The assembler will produce a file 'data.mif' to use for inclusion in your Quartus bitstream, and a file 'data.mif.mem' that is used for ModelSim simulation
6. You can either copy the two files into your Quartus project folder, or copy the asm.exe file into your project folder and build the files right there, whatever you preference is
7. If you haven't changed anything about your processor hardware, but want to test a new assembly program on the board  you can update and download your system with a new *.mif file by clicking on the 'UPDATE_MIF.bat' batch file in the Quartus project folder. It is much faster than re-starting the whole Quartus compile. Alternatively, you can call it directly after assembling from the NIOS II console with
	> cmd /C UPDATE_MIF.bat
	
REMEMBER: If you try out hardware changes, SIMULATE them first before trying them on the board. Much easier and faster to debug.