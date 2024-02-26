# Quick_Encrypter
The code works by changing every byte in a given file according to a table that is generated based on a seed that works as a key to encrypt and decrypt files.
<br>
<br>
**NOTE:** Not Secure, I don't recommend using it with important files. It was made just for fun and educational purposes.
<br>
<br>
**NOTE_2:** Although it's kinda fast, it works by reading the whole file as one big chunk. If there is not enough RAM, it starts creating swaps, and the speed goes down.
<br>
<br>

## Download
```bash
git clone https://github.com/Stachu1/Quick_Encrypter.git
```

<br>


## Run
```bash
cd Quick_Encrypter 
```
```bash
zig build-exe ./src/main.zig
```
```bash
./main <file> <e/d> <key>
```

## Demo
**175MB**<br>
<img width="600" alt="image" src="https://github.com/Stachu1/Quick_Encrypter/assets/77758413/6d7072f4-dd3f-4f0d-96d9-1a0b248d351c">
<br>
<br>

**1GB**<br>
<img width="600" alt="image" src="https://github.com/Stachu1/Quick_Encrypter/assets/77758413/25da6b84-9d20-4ddb-a3f3-e30ef076f1e9">

<br>
<br>

**5GB**<br>
<img width="600" alt="image" src="https://github.com/Stachu1/Quick_Encrypter/assets/77758413/95624be9-ed68-4110-845a-d153ab2fda21">
