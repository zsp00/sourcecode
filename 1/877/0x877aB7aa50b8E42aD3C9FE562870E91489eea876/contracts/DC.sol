// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Degenz Code
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////////////////////////////////
//                                                    //
//                                                    //
//     ___    ___    ___    ___    _   _  _______     //
//    (  _`\ (  _`\ (  _`\ (  _`\ ( ) ( )(_____  )    //
//    | | ) || (_(_)| ( (_)| (_(_)| `\| |     /'/'    //
//    | | | )|  _)_ | |___ |  _)_ | , ` |   /'/'      //
//    | |_) || (_( )| (_, )| (_( )| |`\ | /'/'___     //
//    (____/'(____/'(____/'(____/'(_) (_)(_______)    //
//                                                    //
//                                                    //
//                                                    //
////////////////////////////////////////////////////////


contract DC is ERC721Creator {
    constructor() ERC721Creator("Degenz Code", "DC") {}
}
