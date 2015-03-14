// <The program is called Fx Modulator Delay, it is based on frequency modulator.>
//    Copyright (C) 2015  <Oscar Tuxpan & Daniel Reyes>

//   This program is free software: you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation, either version 3 of the License, or
//   any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


import("oscillator.lib");
import("effect.lib");
import("music.lib");
import("filter.lib");

freq1 = hslider("freq1",100,300,600,1):smooth(0.999);
freq2 = hslider("freq2",300,300,500,1):smooth(0.999);
b = hslider("b1",0,0,1,0.01):smooth(0.999);
b2 = hslider("b2",1,1,1000,1):smooth(0.999);


gate = checkbox("active");

vol = hslider("volume",0.0,0,0.9,0.01):smooth(0.999);


samples=hslider("[0]filter [tooltip: Esto es para establecer retraso] [style: knob]",0.05,0.001,1,0.001)*SR*0.001;

depth=hslider("depth lfo",0,-1,1,0.01):smooth(0.999);
speed=hslider("speed lfo",0,1,20,0.1);



//ADSR
attack = vslider("[0] attack",0.01,0,1,0.001);
decay = vslider("[1] decay",0.3,0,1,0.001);
sustain = vslider("[2] sustain",0.5,0,1,0.001);
release = vslider ("[3] release",0.2,0,1,0.001);



mod1 = oscr(freq2)*gate;
mod2 = sawtooth(freq1)*gate;

carry = oscr(freq1*freq2)*gate;



LFO = _<:fdelay(1024,delayLenght)*depth	:*(0.5)
with{
	delayLenght=samples*(1+osc(speed))/2;
};


oneBand(band,nBands,bwRatio,bandGain)=resonbp(bandFreq,bandQ,bandGain)
with{
	bandFreq=25*pow(2,(band+1)*(5/nBands));
	BW=(bandFreq-25*pow(2,band*5/nBands))*bwRatio;
	bandQ=bandFreq/BW;
};

excitator(nBands,att,rel,bwRatio,source,excitation)=source<:par(i,nBands,oneBand(i,nBands,bwRatio,1):amp_follower_ud(att,rel):_,excitation:oneBand(i,nBands,bwRatio)):>_;

outFX = _,_ : excitator(bands,att,rel,bwRatio)
with{
	bands=64;
	exciterGroup(x)=vgroup("fxOut",x);
	excitGroup(x)=vgroup("excitation",x);
	att=exciterGroup(hslider("[0]att excitation[style:knob]",5,0.1,100,0.1)*0.001);
	rel=exciterGroup(hslider("[1]rel excitation[style:knob]",5,0.1,100,0.1)*0.001);
	bwRatio=exciterGroup(hslider("[2]bandWide[style:knob]",0.5,0.1,2,0.01));
	freq=excitGroup(hslider("freq excitantion[style:knob]",330,50,2000,0.1));
	gain=excitGroup(hslider("gain",0.5,0,1,0.01):smooth(0.999));
};




ADSR = hgroup("adsr",adsr(attack,decay,sustain,release));

MOD = carry + ( +(mod1*b)~LFO );


process =  _, ( ( ( ( oscr( (MOD*gate*b2)+freq2) )   ) *(ADSR) )*vol*gate ) : outFX <:_,_;
