 ```shell
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
```
 - mengimpor file ERC721.sol dari OpenZeppelin untuk membuat kontrak ERC721

```shell
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
```
 - mengimpor file ReentrancyGuard.sol dari OpenZeppelin untuk pengamanan terhadap serangan reentrancy
 - address public owner - variabel untuk menyimpan alamat pemilik kontrak
 - uint256 public totalSupply - variabel untuk menyimpan jumlah token yang telah di-mint
 - uint256 public maxSupply - variabel untuk menyimpan jumlah maksimum token yang dapat di-mint
 - uint256 public price - variabel untuk menyimpan harga token
 - string public baseURI - variabel untuk menyimpan base URI untuk metadata token
 - bool public dropEnabled - variabel untuk menyimpan status drop (aktif atau tidak)
 - constructor(string memory _name, string memory _symbol, string memory _baseURI, uint256 _maxSupply, uint256 _price) ERC721(_name, _symbol) - konstruktor kontrak NFTDrop dengan parameter nama, simbol, base URI, maksimum supply, dan harga. Juga memanggil konstruktor kontrak ERC721 dengan nama dan simbol yang sama
 - function startDrop() public onlyOwner - fungsi untuk memulai drop. Hanya pemilik kontrak yang dapat memanggil fungsi ini
`function stopDrop() public only