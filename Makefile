C2HS = c2hs
C2HSFLAGS = 
INTERNAL = src/Codec/Compression/LZ4/Internal
INCLUDEDIR="src/cbits"
lz4:
	$(C2HS) $(C2HSFLAGS) $(INTERNAL)/LZ4.chs
lz4frame:
	$(C2HS) $(C2HSFLAGS) $(INTERNAL)/LZ4Frame.chs
lz4hc:
	$(C2HS) $(C2HSFLAGS) $(INTERNAL)/LZ4HC.chs

c2hs: lz4frame lz4hc lz4

clean:
	rm -f $(INTERNAL)/*.hs
	rm -f $(INTERNAL)/*.chi
	rm -f $(INTERNAL)/*.chs.h
