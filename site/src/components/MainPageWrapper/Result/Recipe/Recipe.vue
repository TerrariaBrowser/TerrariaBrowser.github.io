<template>
  <div class="recipe-wrapper">
    <h5 v-if="showTitle">{{ recipe.result }}</h5>
    <b-table
      :items="ingredientRows"
      :key="recipe.id"
      striped
      hover
      small
      class="small" />
  </div>
</template>

<script>
export default {
  props: {
    recipe: { type: Object, required: true, default: () => {} },
    showTitle: { type: Boolean, required: false, default: true },
  },
  computed: {
    ingredientRows() {
      return Object.keys(this.recipe.ingredients).map(itemName => (
        { item: itemName, amount: this.recipe.ingredients[itemName] }
      ));
    },
  },
};
</script>

<style lang="scss">
@import './Recipe.scss'
</style>
