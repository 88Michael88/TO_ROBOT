The test that we will executed in the dataTransferTest.

Assumptions:

Connection Speed - from 0 to 100 Mbps.
Bearer - must have an ID that is connected to a UE.
Protocol - is either TCP or UDP. 

Possible Tests Cases:

| group nr. | test nr. | Result | Connection Speed | UE ID | Bearer ID | Protocol | Reason | 
| --------- | -------- | ------ | ---------------- | ----- | --------- | -------- | -------| 
| 1.        | 01.      | PASS   | 1 bps            | 7     | 3         | TCP      | |
| 1.        | 02.      | PASS   | 1 Kbps           | 7     | 3         | TCP      | |
| 1.        | 03.      | PASS   | 1 Mbps           | 7     | 3         | TCP      | |
| 1.        | 04.      | PASS   | 50 Mbps          | 7     | 3         | TCP      | |
| 1.        | 05.      | PASS   | 99 Mbps          | 7     | 3         | TCP      | |
| 1.        | 06.      | PASS   | 100 Mbps         | 7     | 3         | TCP      | |
| 1.        | 07.      | FAIL   | 101 Mbps         | 7     | 3         | TCP      | Invalid Connection Speed |
| 2.        | 08.      | PASS   | 1 bps            | 7     | 3         | UDP      | |
| 2.        | 09.      | PASS   | 1 Kbps           | 7     | 3         | UDP      | |
| 2.        | 10.      | PASS   | 1 Mbps           | 7     | 3         | UDP      | |
| 2.        | 11.      | PASS   | 50 Mbps          | 7     | 3         | UDP      | |
| 2.        | 12.      | PASS   | 99 Mbps          | 7     | 3         | UDP      | |
| 2.        | 13.      | PASS   | 100 Mbps         | 7     | 3         | UDP      | |
| 2.        | 14.      | FAIL   | 101 Mbps         | 7     | 3         | UDP      | Invalid Connection Speed |
| 3.        | 15.      | FAIL   | 1 bps            | 7     | 3         | QUIC     | Invalid Protocol |
| 3.        | 16.      | FAIL   | 1 Kbps           | 7     | 3         | QUIC     | Invalid Protocol |
| 3.        | 17.      | FAIL   | 1 Mbps           | 7     | 3         | QUIC     | Invalid Protocol |
| 4.        | 18.      | FAIL   | 1 bps            | 7     | 4         | xxx      | Unregistered Bearer ID |
| 4.        | 19.      | FAIL   | 1 Kbps           | 7     | 4         | xxx      | Unregistered Bearer ID |
| 4.        | 20.      | FAIL   | 1 Mbps           | 7     | 4         | xxx      | Unregistered Bearer ID |
| 5.        | 21.      | FAIL   | 1 bps            | 6     | x         | xxx      | Unregistered UE ID |
| 5.        | 22.      | FAIL   | 1 Kbps           | 6     | x         | xxx      | Unregistered UE ID |
| 5.        | 23.      | FAIL   | 1 Mbps           | 6     | x         | xxx      | Unregistered UE ID |

x - This value is not important.
