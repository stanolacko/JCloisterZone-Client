<template>
  <div
    :class="{
      'rule-select': true,
      'editable': !readOnly,
      short,
      long,
      xlong
    }"
  >
    <v-select
      v-if="!readOnly"
      v-model="value"
      :items="rule.values"
      :disabled="!enabled"
      dense
      hide-details
    />
    <span v-else class="ro-value">{{ title }}</span>
  </div>
</template>

<script>
export default {
  props: {
    setup: { type: Object, required: true },
    rule: { type: Object, required: true },
    enabled: { type: Boolean, default: true },
    short: { type: Boolean, default: false },
    long: { type: Boolean, default: false },
    xlong: { type: Boolean, default: false },
    readOnly: { type: Boolean, defaukt: false }
  },

  computed: {
    value: {
      get () {
        const val = this.setup.rules[this.rule.id]
        return val === undefined ? this.rule.default : val
      },

      set (value) {
        // bound directlu to gemaSetup action
        // not much clear, when setup values is no prop
        // but working hack as dispatching action is only handling for editable rule
        this.$store.dispatch('gameSetup/setRuleConfig', { id: this.rule.id, config: value })
      }
    },

    title () {
      return this.rule.values.find(v => v.value === this.value).text
    }
  }
}
</script>

<style lang="sass">
.rule-select
  display: inline-block

  &.editable
    width: 200px
    padding: 0 2px

    &.short
      width: 120px

    &.long
      width: 300px

    &.xlong
      width: 360px

  .ro-value
    padding: 3px
    border-radius: 3px

    +theme using ($theme)
      background: #{map-get($theme, 'line-color')}

</style>
