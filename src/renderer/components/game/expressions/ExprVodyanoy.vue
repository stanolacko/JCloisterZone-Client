<template>
  <ExprContent :expr="expr">
    <template #title>Vodyanoy</template>
    <template #row>
      -2&ensp;×&ensp;
      <div class="value-units">
        {{ expr.args.meeples }}
        <svg class="meeple" :width="24" :height="24">
          <use :href="`${MEEPLES_SVG}#small-follower`" />
        </svg>
      </div>
      &ensp;
      <slot />=&ensp;
    </template>
  </ExprContent>
</template>

<script>
import ExprContent from '@/components/game/expressions/ExprContent'
import ExprMixin from '@/components/game/expressions/ExprMixin'

const MEEPLES_SVG = require('~/assets/meeples.svg')

export default {
  components: {
    ExprContent
  },

  mixins: [ExprMixin],

  props: {
    expr: { type: Object, required: true }
  },

  data () {
    return { MEEPLES_SVG }
  }

}
</script>
