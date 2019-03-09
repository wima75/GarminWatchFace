/*
 (c) 2015-2019, Marco Wittwer
 MoonCalc is for calculating if a date is full moon or new moon.
 On the garmin watch face, there are two problems: time and memory.
 The calculations for updating the view cannot be more than about one second.
 And the memory size is limited.
 
 My solution was to precalculate the full moon and new moon dates and save
 them in a compressed string. This needs less memory than an array of dates.
 For precalculate and compress see moonphase/moonsCompressed.html
 */

class MoonCalc {
	function IsFullMoon(d,m,y) {
		var x = encodeDate(d,m,y);
		var f = "l3Ej4Ei5Eh6Eg7Ef8Ee9EdwEcxEcyEa1F92F93F84F75F56F57F38F29F1wFvwFuxFuyFs1Gr2Gs3Gr4Gq5Go6Go7Gm8Gk9GkwGjxGjyGh1Hg2Hi3Hg4Hg5He6Hd7Hc8Ha9H9wH8xH8yH61I52I73I64I55I46I37I18Iv8It9IswIrxIryIp1Jo2Jp3Jn4Jn5Jm6Jl7Jj8Ji9JhwJfxJfyJd1Kc2Ke3Kd4Kc5Kb6Ka7K98K79K7wK5xK4yK31L12L33L24L15Lv5Lt6Lt7Ls8Lq9LqwLoxLoyLm1Mk2Mm3Mk4Mk5Mj6Mi7Mh8Mf9MfwMexMdyMc1Na2Nb3N94N85N76N67N58N39N3wN2xN2yNvyNu1Os2Ou3Os4Or5Oq6Op7Oo8Om9OmwOlxOkyOj1Pi2Pj3Pi4Ph5Pf6Pf7Pd8Pb9PbwPaxP9yP81Q72Q93Q74Q75Q56Q47Q38Q19Qu9QuwQsxQsyQr1Rq2Rr3Rp4Rp5Rn6Rm7Rl8Rj9RiwRhxRgyRf1Se2Sg3Se4Se5Sc6Sc7Sa8S99S8wS6xS6yS41T32T53T34T35T26T17Tv7Tt8Ts9TrwTpxTpyTn1Um2Un3Um4Um5Uk6Uk7Uj8Uh9UhwUfxUfyUd1Vb2Vc3Va4Va5V86V87V78V59V5wV4xV3yV21Wv1W23Wv3Wt4Wt5Wr6Wr7Wp8Wo9WowWmxWmyWl1Xj2Xl3Xj4Xi5Xh6Xg7Xe8Xd9XdwXbxXbyXa1Y92Ya3Y94Y85Y66Y67Y48Y29Y2wYvwYuxYuyYt1Zs2Zs3Zr4Zq5Zo6Zo7Zm8Zk9ZkwZixZiyZh1".find(x);
		if(f == null) {
			return false;
		}
		return true;
	}
	
	function IsNewMoon(d,m,y) {
		var x = encodeDate(d,m,y);
		var f = "54E45E36E27E18Eu8Es9EswEqxEqyEo1Fn2Fo3Fn4Fm5Fl6Fk7Fj8Fh9FgwFfxFeyFd1Gb2Gd3Gc4Gb5Ga6Ga7G88G79G6wG4xG4yG21H12H23H14Hu4Hu5Ht6Hs7Hr8Hp9HpwHnxHnyHl1Ik2Il3Ik4Ij5Ii6Ih7Ig8If9IewIdxIcyIb1J92Ja3J84J85J66J57J48J39J2wJ1xJ1yJuyJt1Ks2Kt3Kr4Kr5Kp6Ko7Kn8Kl9KlwKkxKkyKi1Lh2Lj3Lh4Lg5Lf6Le7Lc8Lb9LawL9xL9yL71M62M83M64M65M46M47M28Mv8Mu9MtwMsxMryMq1Np2Nq3No4No5Nm6Nm7Nk8Ni9NiwNgxNgyNe1Od2Of3Od4Od5Oc6Ob7Oa8O89O7wO6xO5yO41P22P43P24P25P16Pu6Pu7Ps8Pr9PqwPpxPoyPn1Ql2Qn3Ql4Ql5Qj6Qj7Qi8Qg9QgwQexQeyQc1Rb2Rb3Ra4R95R86R77R68R49R4wR3xR2yR11Su1S13Su3St4Ss5Sq6Sq7So8Sn9SnwSmxSlySk1Ti2Tk3Ti4Ti5Tg6Tf7Te8Tc9TcwTbxTayT91U82U93U84U75U66U57U38U29U1wUvwUtxUtyUs1Vr2Vr3Vq4Vp5Vo6Vn7Vl8Vk9VjwVixVhyVg1Wf2Wg3Wf4Wf5Wd6Wd7Wb8W99W9wW7xW6yW51X42X53X44X45X36X27X18Xu8Xs9XswXqxXqyXo1Yn2Yo3Yn4Yn5Yl6Yl7Yj8Yi9YhwYgxYfyYe1Zc2Zd3Zb4Zb5Z96Z97Z88Z69Z6wZ4xZ4yZ21".find(x);
		if(f == null) {
			return false;
		}
		return true;
	}
	
	private function encodeDate(d,m,y) {
		return encodeDay(d) + encodeMonth(m) + encodeYear(y);
	}
	
	private function encodeDay(d) {
		if(d>=10) {
			var chars = "abcdefghijklmnopqrstuv";
			var index = d - 10;
			return chars.substring(index, index + 1);
		} else {
			return d.toString();
		}
	}
	
	private function encodeMonth(m) {
		if(m>=10) {
			var chars = "wxy";
			var index = m - 10;
			return chars.substring(index, index + 1);
		} else {
			return m.toString();
		}
	}
	
	private function encodeYear(y) {
		var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		var index = y - 2015;
		return chars.substring(index, index + 1);
	}
}