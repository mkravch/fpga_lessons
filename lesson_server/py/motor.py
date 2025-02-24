import mmap

def write_to_reg(addr,data):

        with open("/dev/mem", "r+b") as f:
            mm = mmap.mmap(f.fileno(), 4*(addr + 1), offset=0x43C00000)

        byte = [0]*4
        print(byte)
        
        byte[0] = data & 0xff
        byte[1] = (data>>8) & 0xff
        byte[2] = (data>>16) & 0xff
        byte[3] = (data>>24) & 0xff
	
        for i in range(0,4):
            mm[addr*4 + i] = byte[i]

        mm.close()


data = 100
write_to_reg(1,data)

data = (500000<<1)
write_to_reg(0,data)

data = (500000<<1) + 1
write_to_reg(0,data)
