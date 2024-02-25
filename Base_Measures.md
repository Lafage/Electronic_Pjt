Nb idby Month = 
MAXX(
	KEEPFILTERS(VALUES('Calendar'[Month])),
	CALCULATE(COUNTA('Dataset'[id]))
)
