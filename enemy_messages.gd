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
	}
}

func fetc_message(enemy_name, type):
	return msgs[enemy_name][type]
