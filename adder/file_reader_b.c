void file_reader_b(){
	unsigned temp;
	while(1){
		temp = file_read("stim_b");
		output_z(temp);
	}
}
