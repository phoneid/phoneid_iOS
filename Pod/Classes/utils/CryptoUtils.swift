//
//  CryptoUtils.swift
//  phoneid_iOS
//
//  Copyright 2015 phone.id - 73 knots, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import Foundation

let SHA1_DIGEST_LENGTH = 20

extension String {
    func sha1() -> String {
        let data: NSMutableData = self.dataUsingEncoding(NSUTF8StringEncoding)!.mutableCopy() as! NSMutableData
        let dataLen = data.length

        var value: UInt8 = 0x80
        data.appendBytes(&value, length: 1) // append one bit to data

        var msgLength = data.length
        var counter = 0

        let len: Int = 64
        while msgLength % len != (len - 8) {
            counter += 1
            msgLength += 1
        }

        let bufZeros = UnsafeMutablePointer<UInt8>(calloc(counter, sizeof(UInt8)))

        data.appendBytes(bufZeros, length: counter)

        bufZeros.destroy()
        bufZeros.dealloc(1)

        let h: [UInt32] = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0]
        var hh = h

        var value4: UInt64 = UInt64(dataLen * sizeof(UInt64)).bigEndian
        data.appendBytes(&value4, length: sizeof(UInt64));

        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 64
        var leftMessageBytes = data.length
        
        var i = 0
        while i < data.length {
            let chunk = data.subdataWithRange(NSRange(location: i, length: min(chunkSizeBytes, leftMessageBytes)))

            // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15, big-endian
            // Extend the sixteen 32-bit words into eighty 32-bit words:
            var M: [UInt32] = [UInt32](count: 80, repeatedValue: 0)
            for x in 0 ..< M.count {
                switch (x) {
                case 0 ... 15:
                    var le: UInt32 = 0
                    chunk.getBytes(&le, range: NSRange(location: x * sizeofValue(M[x]), length: sizeofValue(M[x])));
                    M[x] = le.bigEndian
                    break
                default:
                    M[x] = shiftLeft(M[x - 3] ^ M[x - 8] ^ M[x - 14] ^ M[x - 16], n: 1)
                    break
                }
            }

            var A = hh[0]
            var B = hh[1]
            var C = hh[2]
            var D = hh[3]
            var E = hh[4]

            // Main loop
            for j in 0 ... 79 {
                var f: UInt32 = 0;
                var k: UInt32 = 0

                switch (j) {
                case 0 ... 19:
                    f = (B & C) | ((~B) & D)
                    k = 0x5A827999
                    break
                case 20 ... 39:
                    f = B ^ C ^ D
                    k = 0x6ED9EBA1
                    break
                case 40 ... 59:
                    f = (B & C) | (B & D) | (C & D)
                    k = 0x8F1BBCDC
                    break
                case 60 ... 79:
                    f = B ^ C ^ D
                    k = 0xCA62C1D6
                    break
                default:
                    break
                }

                let temp = (shiftLeft(A, n: 5) &+ f &+ E &+ M[j] &+ k) & 0xffffffff
                E = D
                D = C
                C = shiftLeft(B, n: 30)
                B = A
                A = temp
            }

            hh[0] = (hh[0] &+ A) & 0xffffffff
            hh[1] = (hh[1] &+ B) & 0xffffffff
            hh[2] = (hh[2] &+ C) & 0xffffffff
            hh[3] = (hh[3] &+ D) & 0xffffffff
            hh[4] = (hh[4] &+ E) & 0xffffffff
            
            i = i + chunkSizeBytes
            leftMessageBytes -= chunkSizeBytes
        }

        // Produce the final hash value (big-endian) as a 160 bit number:
        let digest: NSMutableData = NSMutableData();
        for item in hh {
            var i: UInt32 = item.bigEndian
            digest.appendBytes(&i, length: sizeofValue(i))
        }


        var bytes = [UInt8](count: SHA1_DIGEST_LENGTH, repeatedValue: 0)
        digest.getBytes(&bytes, length: SHA1_DIGEST_LENGTH)

        let result = NSMutableString()
        for byte in bytes {
            result.appendFormat("%02x", UInt(byte))
        }

        return NSString(string: result) as String

    }
}

func shiftLeft(v: UInt32, n: UInt32) -> UInt32 {
    return ((v << n) & 0xFFFFFFFF) | (v >> (32 - n))
}