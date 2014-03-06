function ShowStaircaseResults(results)

if nargin < 1, error('Not enough input arguments.'); end

figure;
hold on
ylim(10.^[floor(log10(min(results.x))),ceil(log10(max(results.x)))]);
if ~isnan(results.icvg)
    area([results.icvg,results.n], results.x0(3)*[1,1], results.x0(1), 'FaceColor', [0.8,1.0,0.8], 'EdgeColor', 'none');
    plot([results.icvg,results.n], results.x0(2)*[1,1], 'g-');
    plot(results.icvg*[1,1], ylim, 'k-');
end
plot(results.istp, results.x(results.istp), 'b-');
plot(results.irev, results.x(results.irev), 'r.');
plot(results.idec(1:results.ndec), results.x(results.idec(1:results.ndec)), 'ro');
hold off
set(gca, 'Layer', 'top', 'YScale', 'lin', 'Box', 'on');
xlabel('Trial index');
ylabel('Psychophysical variable');
title(sprintf('Psychophysical threshold = %.2g = 10^{%.2f}, probability correct = %.3f', results.x0(2), log10(results.x0(2)), results.pc));
