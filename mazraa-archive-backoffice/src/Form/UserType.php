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
                    'pattern' => '^[a-zA-Z0-9_]+$',
                    'minlength' => 3,
                    'maxlength' => 50,
                ],
                'help' => 'Le nom d\'utilisateur doit contenir entre 3 et 50 caractères (lettres, chiffres et underscore uniquement).',
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
                    'minlength' => 8,
                ],
                'help' => 'Le mot de passe doit contenir au moins 8 caractères.',
            ])
            ->add('role', ChoiceType::class, [
                'label' => 'Rôle',
                'choices' => [
                    'Utilisateur' => User::ROLE_USER,
                    'Administrateur' => User::ROLE_ADMIN,
                ],
                'expanded' => false,
                'multiple' => false,
                'attr' => ['class' => 'form-select'],
            ])
            
            ->add('enabled', ChoiceType::class, [
                'label' => 'Compte actif',
                'choices' => [
                    'Actif' => true,
                    'Inactif' => false,
                ],
                'expanded' => true,
                'multiple' => false,
                'data' => true,
                'label_attr' => ['class' => 'form-check-label'],
                'attr' => ['class' => 'form-check-input'],
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