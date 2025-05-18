<?php
// src/Form/DocumentFormType.php
namespace App\Form;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\Extension\Core\Type\TextareaType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
use Symfony\Component\OptionsResolver\OptionsResolver;
use App\Model\Document;

class DocumentFormType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('title', TextType::class, ['label' => 'Titre'])
            ->add('documentType', ChoiceType::class, [
                'label' => 'Type de document',
                'choices' => $options['document_type_choices'],
                'placeholder' => 'Sélectionnez un type'
            ])
            ->add('barcode', TextType::class, ['label' => 'Code-barres'])
            ->add('storageLocation', ChoiceType::class, [
                'label' => 'Emplacement de stockage',
                'choices' => $options['storage_location_choices'],
                'placeholder' => 'Sélectionnez un emplacement'
            ])
            ->add('status', ChoiceType::class, [
                'label' => 'Statut',
                'choices' => [
                    'Actif' => 'ACTIVE',
                    'Archivé' => 'ARCHIVED',
                    'Retiré' => 'RETRIEVED',
                    'Détruit' => 'DESTROYED',
                ]
            ])
            ->add('description', TextareaType::class, [
                'label' => 'Description',
                'required' => false,
                'attr' => ['rows' => 3],
            ]);
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Document::class,
            'document_type_choices' => [],
            'storage_location_choices' => [],
        ]);
    }
}
