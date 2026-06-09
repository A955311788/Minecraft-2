output "public_ip" {
  description = "Public IP address of the Minecraft server"
  value       = aws_instance.minecraft.public_ip
}

output "minecraft_address" {
  description = "Minecraft server address"
  value       = "${aws_instance.minecraft.public_ip}:25565"
}
