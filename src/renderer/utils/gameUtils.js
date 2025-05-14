import { getAppVersion } from '@/utils/version';
import { Rule } from '@/models/rules';
import { pick, omit } from 'lodash';

export function isSameFeature (f1, f2) {
  return f1.position[0] === f2.position[0] && f1.position[1] === f2.position[1] && f1.location === f2.location
}

export function getMeeplePlayer (meepleId) {
  return parseInt(meepleId.split('.')[0])
}
export function generateSaveContent(state, onlySetup = false) {
  const rules = {};
  Rule.all().forEach(r => {
    const value = state.setup.rules[r.id] ?? r.default;
    if (r.default !== value) rules[r.id] = value;
  });

  const setup = { ...state.setup, rules };

  if (onlySetup) {
    return {
      appVersion: getAppVersion(),
      created: (new Date()).toISOString(),
      setup
    };
  } else {
    const clock = state.lastMessageClock + Date.now() - state.lastMessageClockLocal;
    const content = {
      appVersion: state.originAppVersion || getAppVersion(),
      gameId: state.id,
      name: '',
      initialRandom: state.initialRandom,
      created: (new Date()).toISOString(),
      clock,
      setup,
      players: state.players.map(p => ({
        name: p.name,
        slot: p.slot,
        clientId: p.clientId
      })),
      replay: state.gameMessages.map(m => {
        m = pick(m, ['type', 'payload', 'player', 'clock']);
        m.payload = omit(m.payload, ['gameId']);
        return m;
      })
    };

    if (Object.keys(state.gameAnnotations).length) {
      content.gameAnnotations = state.gameAnnotations;
    }

    return content;
  }
}
