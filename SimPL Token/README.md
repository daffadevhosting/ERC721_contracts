```shell
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";
```
 - mengimpor file ERC20Burnable.sol dari OpenZeppelin untuk menambahkan fitur burnable
contract MyToken is ERC20, ERC20Burnable, ReentrancyGuard
 - MyToken adalah kontrak ERC20 yang juga menggunakan ERC20Burnable dan ReentrancyGuard
function transfer(address recipient, uint256 amount) public virtual override nonReentrant returns (bool)
 - menggunakan modifier nonReentrant dari ReentrancyGuard untuk mencegah serangan reentrancy pada fungsi transfer
Fungsi burn bawaan dari kontrak ERC20Burnable akan digunakan untuk membakar token dari pengirim
Dengan menggunakan kontrak ERC20 ini, pengguna dapat membakar token mereka menggunakan fungsi burn dan token yang dibakar akan dihapus dari total pasokan yang beredar.