function  fastslam2( lm, wp )
% Initialisations
particles= initialise_particles(100);
xtrue= zeros(3,1);

index_wp=1;    % index to first waypoint
G= 0;               % initial steer angle
V=4                 % m/s

% control noises
sigmaV= 0.3; % m/s
sigmaG= (3.0*pi/180); % radians
Q= [sigmaV^2 0; 0 sigmaG^2];

rateG=0.3491;  %max circle rate
dt=0.025;         %time step (40 op/s)

while index_wp<size(wp,2)
    % compute true data
    % determine if current waypoint reached
    cwp= wp(:,index_wp);
    d2= (cwp(1)-xtrue(1))^2 + (cwp(2)-xtrue(2))^2;
    minD=1;
    if d2 < minD^2
        index_wp= index_wp+1; % switch to next
        if index_wp > size(wp,2) % reached final waypoint, flag and return
            break;
        end
        cwp= wp(:,index_wp); % next waypoint
    end
    % compute change in G to point towards current waypoint
    deltaG= pi_to_pi(atan2(cwp(2)-x(2), cwp(1)-x(1)) - x(3) - G);
    
    % limit rate
    maxDelta= rateG*dt;
    if abs(deltaG) > maxDelta
        deltaG= sign(deltaG)*maxDelta;
    end
    
    % limit angle
    G= G+deltaG;
    if abs(G) > maxG
        G= sign(G)*maxG;
    end
    
    xtrue= [xtrue(1) + V*dt*cos(G+xtrue(3,:)); 
     xtrue(2) + V*dt*sin(G+xtrue(3,:));
     pi_to_pi(xtrue(3) + V*dt*sin(G)/WB)];
    
    % add process noise
    [Vn,Gn]= add_control_noise(V,G,Q, 1);
    
end
end

function p= initialise_particles(np)
for i=1:np
    p(i).w= 1/np;           %weight
    p(i).xv= [0;0;0];       %sample of  pose
    p(i).Pv= zeros(3);     %covariation of pose prodict
    p(i).xf= [];
    p(i).Pf= [];
    p(i).da= [];
end
end