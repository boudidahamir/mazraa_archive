<?php

namespace App\Form;

use App\Model\User;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
use Symfony\Component\Form\Extension\Core\Type\EmailType;
use Symfony\Component\Form\Extension\Core\Type\PasswordType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;

class UserType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('username', TextType::class, [
                'label' => 'Nom d\'utilisateur',
                'attr' => [
                    'class' => 'form-control',
                    'placeholder' => 'Entrez le nom d\'utilisateur',
                ],
            ])
            ->add('email', EmailType::class, [
                'label' => 'Email',
                'attr' => [
                    'class' => 'form-control',
                    'placeholder' => 'Entrez l\'email',
                ],
            ])
            ->add('fullName', TextType::class, [
                'label' => 'Nom complet',
                'attr' => [
                    'class' => 'form-control',
                    'placeholder' => 'Entrez le nom complet',
                ],
            ])
            
            ->add('plainPassword', PasswordType::class, [
                'label' => 'Mot de passe',
                'required' => !$options['is_edit'],
                'mapped' => false,
                'attr' => [
                    'class' => 'form-control',
                    'placeholder' => $options['is_edit'] ? 'Laissez vide pour ne pas modifier' : 'Entrez le mot de passe',
                ],
            ])
            ->add('role', ChoiceType::class, [
                'label' => 'Rôle',
                'choices' => [
                    'Utilisateur' => 'USER',
                    'Administrateur' => 'ADMIN',
                ],
                'expanded' => true, // boutons radio
                'multiple' => false,
                'attr' => ['class' => 'form-check'],
            ])
            
            ->add('enabled', ChoiceType::class, [
                'label' => 'Statut',
                'choices' => [
                    'Actif' => true,
                    'Inactif' => false,
                ],
                'expanded' => true,
                'attr' => [
                    'class' => 'form-check',
                ],
            ])
            
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => User::class,
            'is_edit' => false,
        ]);
    }
} 