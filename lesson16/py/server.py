import telebot;
import mmap

bot = telebot.TeleBot('');

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


@bot.message_handler(content_types=['text'])
def get_text_messages(message):

    if message.text == "Старт":
        bot.send_message(message.from_user.id, "Введите направление")
        bot.register_next_step_handler(message, get_direction);
    else:
        bot.send_message(message.from_user.id, "Я тебя не понимаю. Напиши /help.")


direction = 0

def get_direction(message):

    global direction

    if message.text == "По":
        direction = 1
    else:
        direction = 0

    bot.send_message(message.from_user.id, "Введите угол")
    bot.register_next_step_handler(message, get_angle);


def get_angle(message):

    global direction

    angle = int(message.text)

    write_to_fpga(direction,angle)

def write_to_fpga(direction,angle):

    print(direction)
    print(angle)

    data = angle + (direction << 16)
    write_to_reg(1,data)

    data = (500000<<1)
    write_to_reg(0,data)

    data = (500000<<1) + 1
    write_to_reg(0,data)
    
while(True):
    try:
        bot.polling(none_stop=True, interval=0)
    except:
        print("Error")
    
