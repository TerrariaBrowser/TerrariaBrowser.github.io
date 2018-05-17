<template>
  <div class="recipe-wrapper">
    <h6 v-if="showTitle">
      {{ recipe.result }}
    </h6>
    <b-table
      :items="ingredientRows"
      :key="recipe.id"
      :fields="fields"
      striped
      hover
      small
      class="small ingredients-table">
      <template
        slot="image"
        slot-scope="data">
        <img
          v-if="recipeResultItem"
          :src="recipeResultItemImage">
      </template>
    </b-table>
  </div>
</template>

<script>
export default {
  props: {
    recipe: { type: Object, required: true, default: () => {} },
    showTitle: { type: Boolean, required: false, default: true },
  },
  data() {
    return {
      fields: [
        {
          key: 'image',
          label: '',
          class: 'recipe-image',
          tdAttr: () => ({ rowspan: this.ingredientRows.length }),
        },
        { key: 'itemName', label: 'Item' },
        { key: 'amount' },
      ],
    };
  },
  computed: {
    recipeResultItem() {
      return this.$store.getters.getItemByName(this.recipe.result);
    },
    recipeResultItemImage() {
      const item = this.recipeResultItem;
      return item ? `/static/images/items/Item_${item.itemid}.png` : '';
    },
    ingredientRows() {
      return Object.keys(this.recipe.ingredients).map(itemName => (
        { itemName, amount: this.recipe.ingredients[itemName] }
      ));
    },
  },
};
</script>

<style lang="scss">
@import './Recipe.scss'
</style>
