-- MySQL Script generated by MySQL Workbench
-- Fri Mar 20 22:44:05 2015
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema tucha
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `tucha` ;

-- -----------------------------------------------------
-- Schema tucha
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `tucha` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `tucha` ;

-- -----------------------------------------------------
-- Table `tucha`.`person`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`person` ;

CREATE TABLE IF NOT EXISTS `tucha`.`person` (
  `id` INT NOT NULL,
  `name` VARCHAR(128) NULL,
  `address` VARCHAR(128) NULL,
  `city` VARCHAR(128) NULL,
  `phone` VARCHAR(128) NULL,
  `email` VARCHAR(128) NULL,
  `new_adoption_allowed` BIT(1) NULL,
  `details` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tucha`.`veterinary`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`veterinary` ;

CREATE TABLE IF NOT EXISTS `tucha`.`veterinary` (
  `id` INT NOT NULL,
  `name` VARCHAR(128) NULL,
  `address` VARCHAR(128) NULL,
  `details` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`));


-- -----------------------------------------------------
-- Table `tucha`.`animal`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`animal` ;

CREATE TABLE IF NOT EXISTS `tucha`.`animal` (
  `id` INT NOT NULL,
  `name` VARCHAR(128) NULL,
  `species` VARCHAR(128) NULL,
  `gender` INT(1) NULL,
  `breed` VARCHAR(128) NULL,
  `extimated_age` INT NULL,
  `size` VARCHAR(128) NULL,
  `color` VARCHAR(128) NULL,
  `physical_state` VARCHAR(128) NULL,
  `emotional_state` VARCHAR(128) NULL,
  `details` VARCHAR(2048) NULL,
  `is_adoptable` BIT(1) NULL,
  `is_adoptable_reason` VARCHAR(2048) NULL,
  `received_by` INT NULL,
  `received_from` INT NULL,
  `received_date` DATETIME NULL,
  `received_reason` VARCHAR(2048) NULL,
  `received_details` VARCHAR(2048) NULL,
  `chip_code` VARCHAR(128) NULL,
  `is_sterilizated` BIT(1) NULL,
  `sterilization_date` DATETIME NULL,
  `sterilization_by` INT NULL,
  `sterilization_details` VARCHAR(2048) NULL,
  `is_dead` BIT(1) NULL,
  `death_date` DATETIME NULL,
  `death_reason` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`),
  INDEX `receivedBy_idx` (`received_by` ASC),
  INDEX `received_from_idx` (`received_from` ASC),
  INDEX `sterilization_by_idx` (`sterilization_by` ASC),
  CONSTRAINT `animal_received_by`
    FOREIGN KEY (`received_by`)
    REFERENCES `tucha`.`person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `animal_received_from`
    FOREIGN KEY (`received_from`)
    REFERENCES `tucha`.`person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `animal_sterilization_by`
    FOREIGN KEY (`sterilization_by`)
    REFERENCES `tucha`.`veterinary` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tucha`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`user` ;

CREATE TABLE IF NOT EXISTS `tucha`.`user` (
  `username` VARCHAR(128) NOT NULL,
  `password_hash` CHAR(128) NOT NULL,
  `person` INT NOT NULL,
  `role` VARCHAR(128) NULL,
  PRIMARY KEY (`username`),
  INDEX `person_idx` (`person` ASC),
  CONSTRAINT `user_person`
    FOREIGN KEY (`person`)
    REFERENCES `tucha`.`person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tucha`.`medical_exam`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`medical_exam` ;

CREATE TABLE IF NOT EXISTS `tucha`.`medical_exam` (
  `id` INT NOT NULL,
  `animal` INT NOT NULL,
  `date` DATETIME NULL,
  `veterinary` INT NULL,
  `details` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`),
  INDEX `animal_idx` (`animal` ASC),
  INDEX `veterinary_idx` (`veterinary` ASC),
  CONSTRAINT `medical_exam_animal`
    FOREIGN KEY (`animal`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `medical_exam_veterinary`
    FOREIGN KEY (`veterinary`)
    REFERENCES `tucha`.`veterinary` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tucha`.`vaccination`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`vaccination` ;

CREATE TABLE IF NOT EXISTS `tucha`.`vaccination` (
  `id` INT NOT NULL,
  `animal` INT NOT NULL,
  `date` DATETIME NULL,
  `veterinary` INT NULL,
  `details` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`),
  INDEX `animal_idx` (`animal` ASC),
  INDEX `veterinary_idx` (`veterinary` ASC),
  CONSTRAINT `vaccination_animal`
    FOREIGN KEY (`animal`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `vaccination_veterinary`
    FOREIGN KEY (`veterinary`)
    REFERENCES `tucha`.`veterinary` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tucha`.`deparasitation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`deparasitation` ;

CREATE TABLE IF NOT EXISTS `tucha`.`deparasitation` (
  `id` INT NOT NULL,
  `animal` INT NOT NULL,
  `date` DATETIME NULL,
  `veterinary` INT NULL,
  `details` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`),
  INDEX `animal_idx` (`animal` ASC),
  INDEX `veterinary_idx` (`veterinary` ASC),
  CONSTRAINT `deparasitation_animal`
    FOREIGN KEY (`animal`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `deparasitation_veterinary`
    FOREIGN KEY (`veterinary`)
    REFERENCES `tucha`.`veterinary` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tucha`.`medical_treatment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`medical_treatment` ;

CREATE TABLE IF NOT EXISTS `tucha`.`medical_treatment` (
  `id` INT NOT NULL,
  `animal` INT NOT NULL,
  `date` DATETIME NULL,
  `veterinary` INT NULL,
  `details` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`),
  INDEX `veterinary_idx` (`veterinary` ASC),
  INDEX `animal_idx` (`animal` ASC),
  CONSTRAINT `medical_treatment_veterinary`
    FOREIGN KEY (`veterinary`)
    REFERENCES `tucha`.`veterinary` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `medical_treatment_animal`
    FOREIGN KEY (`animal`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tucha`.`medicament_prescription`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`medicament_prescription` ;

CREATE TABLE IF NOT EXISTS `tucha`.`medicament_prescription` (
  `id` INT NOT NULL,
  `animal` INT NOT NULL,
  `date` DATETIME NULL,
  `veterinary` INT NULL,
  `details` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`),
  INDEX `animal_idx` (`animal` ASC),
  INDEX `veterinary_idx` (`veterinary` ASC),
  CONSTRAINT `medicament_prescription_animal`
    FOREIGN KEY (`animal`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `medicament_prescription_veterinary`
    FOREIGN KEY (`veterinary`)
    REFERENCES `tucha`.`veterinary` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tucha`.`aggressivity_report`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`aggressivity_report` ;

CREATE TABLE IF NOT EXISTS `tucha`.`aggressivity_report` (
  `id` INT NOT NULL,
  `animal` INT NOT NULL,
  `date` DATETIME NULL,
  `user` INT NULL,
  `details` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`),
  INDEX `animal_idx` (`animal` ASC),
  CONSTRAINT `aggressivity_report_animal`
    FOREIGN KEY (`animal`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tucha`.`escape_report`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`escape_report` ;

CREATE TABLE IF NOT EXISTS `tucha`.`escape_report` (
  `id` INT NOT NULL,
  `animal` INT NOT NULL,
  `date` DATETIME NULL,
  `details` VARCHAR(2048) NULL,
  `returned_date` DATETIME NULL,
  PRIMARY KEY (`id`),
  INDEX `animal_idx` (`animal` ASC),
  CONSTRAINT `escape_report_animal`
    FOREIGN KEY (`animal`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tucha`.`adoption`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`adoption` ;

CREATE TABLE IF NOT EXISTS `tucha`.`adoption` (
  `id` INT NOT NULL,
  `animal` INT NOT NULL,
  `date` DATETIME NULL,
  `details` VARCHAR(2048) NULL,
  `adoptant` INT NULL,
  PRIMARY KEY (`id`),
  INDEX `animal_idx` (`animal` ASC),
  INDEX `adoptant_idx` (`adoptant` ASC),
  CONSTRAINT `adoption_animal`
    FOREIGN KEY (`animal`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `adoption_adoptant`
    FOREIGN KEY (`adoptant`)
    REFERENCES `tucha`.`person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tucha`.`medicament`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`medicament` ;

CREATE TABLE IF NOT EXISTS `tucha`.`medicament` (
  `id` INT NOT NULL,
  `name` VARCHAR(128) NULL,
  `details` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tucha`.`supplier`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`supplier` ;

CREATE TABLE IF NOT EXISTS `tucha`.`supplier` (
  `id` INT NOT NULL,
  `name` VARCHAR(128) NULL,
  `address` VARCHAR(128) NULL,
  `phone` VARCHAR(128) NULL,
  `email` VARCHAR(128) NULL,
  `details` VARCHAR(2048) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tucha`.`medicament_unit`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`medicament_unit` ;

CREATE TABLE IF NOT EXISTS `tucha`.`medicament_unit` (
  `id` INT NOT NULL,
  `medicament` INT NULL,
  `details` VARCHAR(2048) NULL,
  `used` BIT(1) NULL,
  `used_in` INT NULL,
  `opening_date` DATETIME NULL,
  `expiration_date` DATETIME NULL,
  `bought_in` INT NULL,
  `bought_by` INT NULL,
  `donated_by` INT NULL,
  `acquired_date` DATETIME NULL,
  `unitary_price` INT NULL,
  `initial_quantity` INT NULL,
  `remaining_quantity` INT NULL,
  PRIMARY KEY (`id`),
  INDEX `medicament_idx` (`medicament` ASC),
  INDEX `used_in_idx` (`used_in` ASC),
  INDEX `bought_in_idx` (`bought_in` ASC),
  INDEX `bought_by_idx` (`bought_by` ASC),
  INDEX `donated_by_idx` (`donated_by` ASC),
  CONSTRAINT `medicament_unit_medicament`
    FOREIGN KEY (`medicament`)
    REFERENCES `tucha`.`medicament` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `medicament_unit_used_in`
    FOREIGN KEY (`used_in`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `medicament_unit_bought_in`
    FOREIGN KEY (`bought_in`)
    REFERENCES `tucha`.`supplier` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `medicament_unit_bought_by`
    FOREIGN KEY (`bought_by`)
    REFERENCES `tucha`.`person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `medicament_unit_donated_by`
    FOREIGN KEY (`donated_by`)
    REFERENCES `tucha`.`person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tucha`.`devolution`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`devolution` ;

CREATE TABLE IF NOT EXISTS `tucha`.`devolution` (
  `id` INT NOT NULL,
  `animal` INT NOT NULL,
  `adoptant` INT NULL,
  `reason` VARCHAR(2048) NULL,
  `date` DATETIME NULL,
  PRIMARY KEY (`id`),
  INDEX `animal_idx` (`animal` ASC),
  INDEX `devolution_adoptant_idx` (`adoptant` ASC),
  CONSTRAINT `devolution_animal`
    FOREIGN KEY (`animal`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `devolution_adoptant`
    FOREIGN KEY (`adoptant`)
    REFERENCES `tucha`.`person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tucha`.`medicament_used`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`medicament_used` ;

CREATE TABLE IF NOT EXISTS `tucha`.`medicament_used` (
  `id` INT NOT NULL,
  `medicament` INT NULL,
  `animal` INT NULL,
  `administrator` INT NULL,
  `prescription` INT NULL,
  `date` DATETIME NULL,
  `quantity` INT NULL,
  `quantity_unit` VARCHAR(128) NULL,
  INDEX `administrator_idx` (`administrator` ASC),
  INDEX `animal_idx` (`animal` ASC),
  PRIMARY KEY (`id`),
  INDEX `medicament_used_prescription_idx` (`prescription` ASC),
  CONSTRAINT `medicament_used_administrator`
    FOREIGN KEY (`administrator`)
    REFERENCES `tucha`.`person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `medicament_used_animal`
    FOREIGN KEY (`animal`)
    REFERENCES `tucha`.`animal` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `medicament_used_medicament`
    FOREIGN KEY (`medicament`)
    REFERENCES `tucha`.`medicament_unit` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `medicament_used_prescription`
    FOREIGN KEY (`prescription`)
    REFERENCES `tucha`.`medicament_prescription` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `tucha`.`medicament_supplier`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tucha`.`medicament_supplier` ;

CREATE TABLE IF NOT EXISTS `tucha`.`medicament_supplier` (
  `supplier` INT NOT NULL,
  `medicament` INT NOT NULL,
  INDEX `supplier_idx` (`supplier` ASC),
  INDEX `medicament_idx` (`medicament` ASC),
  CONSTRAINT `medicament_supplier`
    FOREIGN KEY (`supplier`)
    REFERENCES `tucha`.`supplier` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `supplier_medicament`
    FOREIGN KEY (`medicament`)
    REFERENCES `tucha`.`medicament` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
