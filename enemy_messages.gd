extends Node

enum types{BEGIN, END}

var msgs = {
	"maggots" : {
		types.BEGIN : "a pile of maggots appeared",
		types.END : "maggots run away"
	},
	"flies" : {
		types.BEGIN : "flies",
		types.END : "flies slayed"
	},
	"slime_duo" : {
		types.BEGIN : "slime duo appears",
		types.END : "slime duo dead"
	}
}

func fetc_message(enemy_name, type):
	return msgs[enemy_name][type]

enum attack_types{NORMAL, POISON}
