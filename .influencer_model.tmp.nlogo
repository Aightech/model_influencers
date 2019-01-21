globals
[
  newcomer              ;; an agent who has never collaborated
  component-size        ;; current running size of component being explored
  giant-component-size  ;; size of largest connected component
  components            ;; list of connected components
]

turtles-own
[
  tweeting-from
  activity
  following
  sum-retweeted
  nb-retweeted
  influence
  influence2
]

directed-link-breed [followers follower]

followers-own [
  id
  w
]

links-own
[
  ;new-collaboration?  ;; true if the link represents the first time two agents collaborated
]



to setup
  clear-all
  set-default-shape turtles "circle"
  create-turtles nb-tweetos
  [
    setxy random-xcor mod 50 - 25 random-ycor mod 50 - 25
    set color who * 140 / nb-tweetos + 4
    set activity random tweeting-rate-max
    set nb-retweeted 0

  ]

  ask turtles
  [
;    set following n-of random 2 min-n-of 1 other turtles [distance myself]
    set following n-of random 3 min-n-of 4 other turtles [distance myself]
    foreach sort following
    [
      x -> create-follower-to x
      [
        set color [color] of myself
        set id [who] of x
        set w 0.1
        set thickness w
      ]
    ]

  ]





  reset-ticks
end



to go
  layout-spring turtles followers 0.9 10 10
  ask turtles
  [
    set activity activity + random 3 - 1
    if activity > 100 [ set activity 100]
    if activity < 0 [ set activity 0]
    ifelse random 100 < activity
    [
      ifelse random 2 = 0
      [
        let active-tweetos following with [tweeting-from != -1]
        ifelse empty? sort active-tweetos = false ;if there are active tweetos the turtles is following
        [
          let direct-link max-one-of active-tweetos [influence]
          let interesting-tweetos-id [tweeting-from] of direct-link
          ask out-link-to direct-link
          [
            set w w + 0.01
            set thickness w
          ]
          set tweeting-from interesting-tweetos-id
          ask turtle interesting-tweetos-id [set nb-retweeted nb-retweeted + 1]
        ]
        [
          set tweeting-from who ;; create a new tweet
        ]
      ]
      [;;create a new tweet
        set tweeting-from who
      ]
    ]
    [
      set tweeting-from -1
    ]
    set sum-retweeted sum-retweeted + nb-retweeted
    set influence sum-retweeted / (ticks + 1) * coef-nb-retweeted + coef-nb-follower * count in-link-neighbors + 1 + coef-activity-neightbor * ( sum [activity] of in-link-neighbors) / (count in-link-neighbors + 1)
    set influence2 influence2 + nb-retweeted * coef-nb-retweeted * ( coef-nb-follower * count in-link-neighbors + 1 + coef-activity-neightbor * ( sum [activity] of in-link-neighbors) / (count in-link-neighbors + 1) ) - erosion
    set nb-retweeted 0
    set size influence
  ]

  ask turtles
  [

    foreach sort following
    [
      x ->
      if [tweeting-from] of x != -1
      [
        ask out-link-to x
        [
          if random 5 = 1
          [
            die
          ]
        ]
      ]

    ]
    let nt turtles with [in-link-neighbor? myself = false]
    if random 100 < curiousness and count nt > 2
    [
      let newFollowing n-of random 2 min-n-of 2 other nt [distance myself]
      foreach sort newFollowing
      [
        x -> create-follower-to x
        [
          set color [color] of myself
          set id [who] of x
          set w 0.1
          set thickness w
        ]
      ]
    ]
    set following out-link-neighbors ;[in-links-neighbor] of my-in-links


  ]
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
393
10
1411
1029
-1
-1
10.0
1
10
1
1
1
0
1
1
1
-50
50
-50
50
1
1
1
ticks
30.0

BUTTON
9
20
114
53
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
119
20
224
53
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
11
140
229
173
curiousness
curiousness
0.0
100
19.0
1
1
NIL
HORIZONTAL

SLIDER
13
182
224
215
coef-nb-follower
coef-nb-follower
0.0
1
0.16
0.01
1
NIL
HORIZONTAL

SLIDER
9
61
227
94
nb-tweetos
nb-tweetos
2
50
50.0
1
1
NIL
HORIZONTAL

PLOT
1470
143
1792
332
Link counts
time
cumulative count
0.0
300.0
0.0
10.0
true
false
"" ";; plot stacked histogram of link types\nlet total 0\nset-current-plot-pen \"previous collaborators\"\nplot-pen-up plotxy ticks total\nset total total + count links with [color = red]\nplot-pen-down plotxy ticks total\nset-current-plot-pen \"incumbent-incumbent\"\nplot-pen-up plotxy ticks total\nset total total + count links with [color = yellow]\nplot-pen-down plotxy ticks total\nset-current-plot-pen \"newcomer-incumbent\"\nplot-pen-up plotxy ticks total\nset total total + count links with [color = turquoise]\nplot-pen-down plotxy ticks total\nset-current-plot-pen \"newcomer-newcomer\"\nplot-pen-up plotxy ticks total\nset total total + count links with [color = blue]\nplot-pen-down plotxy ticks total"
PENS
"newcomer-newcomer" 1.0 0 -13345367 true "" ""
"newcomer-incumbent" 1.0 0 -14835848 true "" ""
"incumbent-incumbent" 1.0 0 -1184463 true "" ""
"previous collaborators" 1.0 0 -2674135 true "" ""

SLIDER
11
97
224
130
tweeting-rate-max
tweeting-rate-max
0
100
16.0
1
1
NIL
HORIZONTAL

PLOT
17
362
340
555
influence 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"max" 1.0 0 -16777216 true "" "plot [influence] of one-of turtles with-max [influence]"
"mean" 1.0 0 -7500403 true "" "plot mean [influence] of turtles"
"min" 1.0 0 -2674135 true "" "plot [influence] of one-of turtles with-min [influence]"

SLIDER
12
222
224
255
coef-nb-retweeted
coef-nb-retweeted
0
1
0.18
0.01
1
NIL
HORIZONTAL

SLIDER
13
269
234
302
coef-activity-neightbor
coef-activity-neightbor
0
1
0.04
0.01
1
NIL
HORIZONTAL

SLIDER
11
311
183
344
erosion
erosion
0
1
0.01
0.01
1
NIL
HORIZONTAL

PLOT
16
566
353
791
influence pheromone
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"max" 1.0 0 -16777216 true "" "plot [influence2] of one-of turtles with-max [influence2]"
"mean" 1.0 0 -7500403 true "" "plot mean [influence2] of turtles"
"min" 1.0 0 -2674135 true "" "plot [influence2] of one-of turtles with-min [influence2]"

@#$#@#$#@
## WHAT IS IT?

This model of collaboration networks illustrates how the behavior of individuals in assembling small teams for short-term projects can give rise to a variety of large-scale network structures over time.  It is an adaptation of the team assembly model presented by Guimera, Uzzi, Spiro & Amaral (2005).  The rules of the model draw upon observations of collaboration networks ranging from Broadway productions to scientific publications in psychology and astronomy.

Many of the general features found in the networks of creative enterprises can be captured by the Team Assembly model with two simple parameters: the proportion of newcomers participating in a team and the propensity for past collaborators to work again with one another.

## HOW IT WORKS

At each tick a new team is assembled.  Team members are either inexperienced "newcomers" — people who have not previously participated in any teams -- or are established "incumbents" — experienced people who have previously participated on a team.  Each member is chosen sequentially.  The P slider gives the probability that a new team member will be an incumbent.  If the new member is not a newcomer, then with a probability given by the Q slider, an incumbent will be chosen at random from the pool of previous collaborators of an incumbent already on the team.  Otherwise, a new member will just be randomly chosen from all incumbents.  When a team is created, all members are linked to one another.  If an agent does not participate in a new team for a prolonged period of time, the agent and her links are removed from the network.

Agents in a newly assembled team are colored blue if they are newcomers and yellow if they are incumbents.  Smaller grey circles represent those that are not currently collaborating.  Links indicate members' experience at their most recent time of collaboration.  For example, blue links between agents indicate that two agents collaborated as newcomers.  Green and yellow links correspond to one-time newcomer-incumbent and incumbent-incumbent collaborations, respectively.  Finally, red links indicate that agents have collaborated with one another multiple times.

## HOW TO USE IT

Click the SETUP button to start with a single team.  Click GO ONCE to assemble an additional team.  Click GO to indefinitely assemble new teams.  You may wish to use the GO ONCE button for the first few steps to get a better sense of how the parameters affect the assembly of teams.

### Visualization Controls
- LAYOUT?: controls whether or not the spring layout algorithm runs at each tick.  This procedure attempts to move the nodes around to make the structure of the network easier to see.  Switching off LAYOUT? will significantly increase the speed of the model.

The REDO LAYOUT button lets you run the layout algorithm without assembling new teams.

### Parameters
- TEAM-SIZE: the number of agents in a newly assembled team.
- MAX-DOWNTIME: the number of steps an agent will remain in the world without collaborating before it retires.
- P: the probability an incumbent is chosen to become a member of a new team
- Q: the probability that the team being assembled will include a previous collaborator of an incumbent on the team, given that the team has at least one incumbent.

### Plots
- LINK COUNTS: plots a stacked histogram of the number of links in the collaboration network over time.  The colors correspond to collaboration ties as follows:
-- Blue: two newcomers
-- Green: a newcomer and an incumbent
-- Yellow: two incumbents that have not previously collaborated with one another
-- Red: Repeat collaborators
-  % OF AGENTS IN THE GIANT COMPONENT: plots the percentage of agents belonging to the largest connected component network over time.
- AVERAGE COMPONENT SIZE: plots the average size of isolated collaboration networks as a fraction of the total number of agents

Using the plots, one can observe important features of the network, like the distribution of link types or the connectivity of the network vary over time.

## THINGS TO NOTICE

The model captures two basic features of collaboration networks that can influence or stifle innovation in creative enterprises by varying the values of P and Q.  First is the distribution of the type of the connection between collaborators, which can be seen in the LINK COUNTS plot. An overabundance of newcomer-newcomer (blue) links might indicate that a field is not taking advantage of experienced members. On the other hand, a multitude of repeat collaborations (red) and incumbent-incumbent (yellow) links may indicate a lack of diversity in ideas or experiences.

Second is the overall connectivity of the collaboration network.  For example, many academic fields are said to be comprised of an "invisible college" of loosely connected academic communities.  By contrast, patent networks tend to consist of isolated clusters or chains of inventors.  You can see one measure of this on the % OF AGENTS IN THE GIANT COMPONENT plot -- the giant component being the size of the largest connected chain of collaborators.

You can also see the different emergent topologies in the display.   New collaborations or synergy among teams naturally tend to the center of the display. Teams or clusters of teams with few connections to new collaborations naturally "float" to the edges of the world. Newcomers always start in the center of the world. Incumbents, which are chosen at random, may be located in any part of the screen. Thus, collaborations amongst newcomers and or distant team components tend toward the center, and disconnected clusters are repelled from the centered.

Finally, note that the structure of collaboration networks in the model can change dramatically over time. Initially, only new teams are generated; the collaborative field has not existed long enough for members to retire. However, after a period of time (MAX-DOWNTIME), inactive agents begin to retire, and the number of agents becomes relatively stable -- the emergent effects of P and Q become more apparent in this equilibrium stage.  Note also that the end of the growth stage is often marked by a drop in the connectivity of the network.

## THINGS TO TRY

Keeping Q fixed at 40%, how does the structure of collaboration networks vary with P?  For example, which values of P produce isolated clusters of agents?  As P increases, how do these clusters combine to form more complex structures?  Over which values of P does the transition from a disconnected network to a fully connected network occur?

Set P to 40% and Q to 100%, so that all incumbents choose to work with past collaborators.  Press SETUP, then GO, and let the model run for about 100 steps after the number of agents in the network stops growing.  What happens to the connectivity of the collaboration network?  Keeping P fixed, continue to lower Q in decrements of 5-10%.

Try keeping P and Q constant and varying TEAM-SIZE.  How does the global structure of the network change with larger or smaller team sizes?  Under which ranges of P and Q does this relation hold?

## EXTENDING THE MODEL

What happens when the size of new teams are not constant?  Try changing the rules so that team sizes vary randomly from a distribution or increase over time.

How do P and Q relate to the global clustering coefficient of the network?  You may wish to use code from the Small Worlds model in the Networks section of Sample Models.

Can you modify the model so that agents are more likely to collaborate with collaborators of collaborators?

Collaboration networks can alternatively be thought of as a network consisting of individuals linked to projects.  For example, one can represent a scientific journal with two types of nodes, scientists and publications.  Ties between scientists and publications represent authorship.  Thus, links between a publication multiple scientists specify co-authorship.  More generally, a collaborative project may be represented one type of node, and participants another type.  Can you modify the model to assemble teams using bipartite networks?

## NETLOGO FEATURES

Though it is not used in this model, there exists a network extension for NetLogo that you can download at: https://github.com/NetLogo/NW-Extension.

## RELATED MODELS

Preferential Attachment - gives a generative explanation of how general principles of attachment can give rise to a network structure common to many technological and biological systems.

Giant Component - shows how critical points exist in which a network can transition from a rather disconnected topology to a fully connected topology

## CREDITS AND REFERENCES

This model is based on:
R Guimera, B Uzzi, J Spiro, L Amaral; Team Assembly Mechanisms Determine Collaboration Network Structure and Team Performance. Science 2005, V308, N5722, p697-702 https://amaral.northwestern.edu/media/publication_pdfs/Guimera-2005-Science-308-697.pdf

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Bakshy, E. and Wilensky, U. (2007).  NetLogo Team Assembly model.  http://ccl.northwestern.edu/netlogo/models/TeamAssembly.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2007 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2007 Cite: Bakshy, E. -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
set layout? false
setup repeat 175 [ go ]
repeat 35 [ layout ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.8
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
