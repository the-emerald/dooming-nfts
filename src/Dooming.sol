// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ERC721A/ERC721A.sol";
import "hot-chain-svg/SVG.sol";
import "hot-chain-svg/Utils.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract Dooming is ERC721A, Ownable {
    using Strings for uint256;

    mapping(uint256 => string[]) reason;

    constructor() ERC721A("Dooming", "DOOM") {}

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        string
            memory image = '<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" style="background:#202020">';

        string memory reasons = "";
        uint256 yPos = 40;
        for (uint256 i = 0; i < reason[tokenId].length; i++) {
            image = string.concat(
                image,
                svg.text(
                    string.concat(
                        svg.prop("x", "20"),
                        svg.prop("y", yPos.toString()),
                        svg.prop("font-size", "16"),
                        svg.prop("font-family", "monospace"),
                        svg.prop("fill", "white")
                    ),
                    reason[tokenId][i]
                )
            );
            reasons = string.concat(reasons, " ", reason[tokenId][i]);
            yPos += 40;
        }
        image = string.concat(image, "</svg>");

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Moment #',
                        tokenId.toString(),
                        '", "description": "',
                        reasons,
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(image)),
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    /// @notice Mint a token. Each element in _reason should be <30 characters long, split up long sentences, a space between each line is automatically added.
    /// @param to address to send token to
    /// @param _reason array of strings representing the reason of minting this moment.
    function safeMint(address to, string[] memory _reason) external onlyOwner {
        reason[totalSupply()] = _reason;
        _safeMint(to, 1);
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
