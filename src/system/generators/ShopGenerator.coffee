
_ = require "lodash"
Generator = require "./Generator"
Chance = require "chance"
Constants = require "./../utilities/Constants"
chance = new Chance()

class ShopGenerator extends Generator
  constructor: (@game) ->

  getShopPercent: (player) ->
    # Any lower and the cost would go negative or to 0, which is never an ideal solution.
    1 + ((Math.max -99, player.calc.stat 'shopPercent')/100)

  getFlux: ->
    chance.floating {min: 1, max: 1 + Constants.defaults.game.shopPriceFlux, fixed: 3}

  generateShop: (player) ->
    shop = {}
    shop.item = @generateItem player
    return unless shop.item
    shop.item = @generateItem player while shop.item.score() > player.calc.itemFindRange()*Constants.defaults.game.shopRangeBoost
    shop.price = Math.floor shop.item.score() * @getFlux() * @getShopPercent player
    shop.price = 1 if shop.price <= 0
    shop.price *= 7 # gouge the players for gold, muhahaha
    shop

  regionShop: (player) ->
    shop = {}
    shop.slots = []
    region = player.getRegion()
    shop.region = region.name
    for i in [0...region.shopSlots(player)]
      item = @generateItem player
      return unless item
      item = @generateItem player while item?.score() > player.calc.itemFindRange()*Constants.defaults.game.shopRangeBoost*region.shopQuality(player)
      return unless item
      price = Math.floor item.score() * region.shopMult(player) * @getFlux() * @getShopPercent player
      price = 1 if price <= 0
      price *= 7 # gouge the players for gold, muhahaha
      shop.slots[i] = {item: item, price: price}

    shop

  generateItem: (player) ->
    @game.equipmentGenerator.generateItem null, player.calc.luckBonus()

module.exports = exports = ShopGenerator
