# qsexpand
fast q series expand program for maxima

(%i1) install_github("YasuakiHonda","qsexpand","master")$

(%i2) asdf_load_source("qsexpand");

(%i3) qpoly1:q*product((1-q^n)^24,n,1,inf));

(%i4) qsexpand(qpoly1,100);
