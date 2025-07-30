from tqdm import tqdm

import serial

HEADER_SIZE = 1080
IMAGE_SIZE = 512 * 512 + HEADER_SIZE


def main():
    ser = serial.Serial(port="COM4", baudrate=115200)

    # Send bmp image
    with open("lena_gray.bmp", "rb") as f:
        with tqdm(total=IMAGE_SIZE, unit="bytes", desc="Sending image") as pbar:
            while True:
                data = f.read(ser.in_waiting or 1024)
                if not data:
                    break
                ser.write(data)
                pbar.update(len(data))

    bytes_recv = 0
    bmp = bytearray()

    # Receive processed image
    with tqdm(total=IMAGE_SIZE, unit="bytes", desc="Receiving image") as pbar:
        while True:
            if ser.in_waiting > 0:
                data = ser.read(ser.in_waiting)
                pbar.update(len(data))
                bytes_recv += len(data)
                bmp += data

            if bytes_recv >= 512 * 512 + 1080:
                break

    with open("lena_gray_binarization.bmp", "wb") as f:
        f.write(bmp)


if __name__ == "__main__":
    main()
