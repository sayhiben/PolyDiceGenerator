// Utility functions for PolyDiceGenerator
// Common helper functions used across different dice types

// Fix quotes in arrays - converts string "undef" to actual undef
function fix_quotes(x) = [
    for (i = x) 
        if (i == "undef" || i == undef) undef 
        else if (i == "true" || i == true) true 
        else if (i == "false" || i == false) false 
        else i
];

// Merge text and symbols - replaces text with symbols where specified
function merge_txt(dist, sym) = [
    for (a = [0:len(dist)-1]) 
        if (sym[a] == "undef" || sym[a] == undef) dist[a] 
        else [sym[a]]
];

// Adjust list values by multiplier
function adj_list(list, val) = [
    for (a = [0:len(list)-1]) 
        list[a] * val
];