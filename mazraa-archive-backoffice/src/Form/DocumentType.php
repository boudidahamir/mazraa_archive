<?php

namespace App\Form;

use App\Entity\Document;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
use Symfony\Component\Form\Extension\Core\Type\TextareaType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;

class DocumentType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('title', TextType::class, [
                'label' => 'Titre',
                'attr' => ['placeholder' => 'Entrez le titre du document']
            ])
            ->add('documentType', ChoiceType::class, [
                'label' => 'Type de document',
                'choices' => [
                    'Facture' => 'INVOICE',
                    'Contrat' => 'CONTRACT',
                    'Rapport' => 'REPORT',
                    'Autre' => 'OTHER'
                ],
                'placeholder' => 'Sélectionnez un type'
            ])
            ->add('barcode', TextType::class, [
                'label' => 'Code-barres',
                'attr' => ['placeholder' => 'Entrez le code-barres']
            ])
            ->add('description', TextareaType::class, [
                'label' => 'Description',
                'required' => false,
                'attr' => [
                    'placeholder' => 'Entrez une description du document',
                    'rows' => 5
                ]
            ])
            ->add('storageLocation', TextType::class, [
                'label' => 'Emplacement de stockage',
                'attr' => ['placeholder' => 'Entrez l\'emplacement de stockage']
            ])
            ->add('status', ChoiceType::class, [
                'label' => 'Statut',
                'choices' => [
                    'Actif' => 'ACTIVE',
                    'Archivé' => 'ARCHIVED',
                    'Retiré' => 'RETRIEVED',
                    'Détruit' => 'DESTROYED'
                ]
            ])
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Document::class,
        ]);
    }
} 