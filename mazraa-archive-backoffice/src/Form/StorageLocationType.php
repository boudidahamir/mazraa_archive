<?php

namespace App\Form;

use App\Model\StorageLocation;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\Extension\Core\Type\TextareaType;
use Symfony\Component\Form\Extension\Core\Type\CheckboxType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\Extension\Core\Type\IntegerType;

class StorageLocationType extends AbstractType
{

    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('code', TextType::class, [
                'label' => 'Code',
                'attr' => ['placeholder' => 'EX: ZONE_A1']
            ])
            ->add('name', TextType::class, [
                'label' => 'Nom',
                'attr' => ['placeholder' => 'Nom de l\'emplacement']
            ])
            ->add('description', TextareaType::class, [
                'label' => 'Description',
                'required' => false,
                'attr' => ['placeholder' => 'Description']
            ])
            ->add('shelf', TextType::class, [
                'label' => 'Étagère',
                'attr' => ['placeholder' => 'EX: A']
            ])
            ->add('row', TextType::class, [
                'label' => 'Rangée',
                'attr' => ['placeholder' => 'EX: 1']
            ])
            ->add('box', TextType::class, [
                'label' => 'Boîte',
                'attr' => ['placeholder' => 'EX: B2']
            ])
            ->add('capacity', IntegerType::class, [
                'label' => 'Capacité',
                'attr' => ['placeholder' => 'EX: 100']
            ])
            ->add('isActive', CheckboxType::class, [
                'label' => 'Actif',
                'required' => false
            ]);
    }


    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => StorageLocation::class,
        ]);
    }
}