//var items = require('items');
var Drone = require('drone');
/*
exports.testarmor = function(){
  console.log(items.armorStand().isBlock());
  console.log(items.signPost().isBlock());

  var location = self.location ;
  var ars = location.world.spawnEntity(location, org.bukkit.entity.EntityType.ARMOR_STAND)
  ars.setVisible(false);
  ars.setGravity(false);
  ars.setInvulnerable(true);
  ars.setCustomName("xxxars");
  ars.setCustomNameVisible(true);

}
*/
//  summon Armor_Stand ~ ~ ~ {Invulnerable:1b,NoGravity:1b,Invisible:1b,CustomNameVisible:1b,CustomName:I AM AWESOME};

//js location.world.dropItem(location, new org.bukkit.inventory.ItemStack(org.bukkit.Material.ARMOR_STAND))


//js location.world.spawnEntity(location, new org.bukkit.inventory.ItemStack(org.bukkit.Material.ARMOR_STAND))


//js org.bukkit.command.summon(Armor_Stand ~ ~ ~ {Invulnerable:1b,NoGravity:1b,Invisible:1b,CustomNameVisible:1b,CustomName:I AM AWESOME})


//js location.world.spawnEntity(location, org.bukkit.entity.EntityType.ARMOR_STAND)

function testarmordrone(){
  this.right(3);
  this.box(1);
  this.fwd(3);
  var location = this.getLocation() ;
  var ars = location.world.spawnEntity(location, org.bukkit.entity.EntityType.ARMOR_STAND)
  ars.setVisible(false);
  ars.setGravity(false);
  ars.setInvulnerable(true);
  ars.setCustomName("xxxars");
  ars.setCustomNameVisible(true);
}

Drone.extend(testarmordrone);
