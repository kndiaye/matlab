function data = om_load_full(filename)
    file = fopen(filename,'r');
    dims = fread(file,2,'uint32','ieee-le');
    data = fread(file,prod(dims),'double','ieee-le');
    data = reshape(data,dims');
    fclose(file);
