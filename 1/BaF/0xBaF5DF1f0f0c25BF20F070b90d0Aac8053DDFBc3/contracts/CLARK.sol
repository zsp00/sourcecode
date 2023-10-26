
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Clarkie
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////////////////////////////////////////////////////////////////////////
//                                                                                     //
//                                                                                     //
//                  ,--,                                                               //
//               ,---.'|                                    ,--.                       //
//      ,----..  |   | :      ,---,       ,-.----.      ,--/  /|   ,---,    ,---,.     //
//     /   /   \ :   : |     '  .' \      \    /  \  ,---,': / ',`--.' |  ,'  .' |     //
//    |   :     :|   ' :    /  ;    '.    ;   :    \ :   : '/ / |   :  :,---.'   |     //
//    .   |  ;. /;   ; '   :  :       \   |   | .\ : |   '   ,  :   |  '|   |   .'     //
//    .   ; /--` '   | |__ :  |   /\   \  .   : |: | '   |  /   |   :  |:   :  |-,     //
//    ;   | ;    |   | :.'||  :  ' ;.   : |   |  \ : |   ;  ;   '   '  ;:   |  ;/|     //
//    |   : |    '   :    ;|  |  ;/  \   \|   : .  / :   '   \  |   |  ||   :   .'     //
//    .   | '___ |   |  ./ '  :  | \  \ ,';   | |  \ |   |    ' '   :  ;|   |  |-,     //
//    '   ; : .'|;   : ;   |  |  '  '--'  |   | ;\  \'   : |.  \|   |  ''   :  ;/|     //
//    '   | '/  :|   ,/    |  :  :        :   ' | \.'|   | '_\.''   :  ||   |    \     //
//    |   :    / '---'     |  | ,'        :   : :-'  '   : |    ;   |.' |   :   .'     //
//     \   \ .'            `--''          |   |.'    ;   |,'    '---'   |   | ,'       //
//      `---`                             `---'      '---'              `----'         //
//                                                                                     //
//                                                                                     //
/////////////////////////////////////////////////////////////////////////////////////////


contract CLARK is ERC721Creator {
    constructor() ERC721Creator("Clarkie", "CLARK") {}
}