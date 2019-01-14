//
//  WelcomePageViewController.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 1/11/19.
//  Copyright © 2019 Charlie Mulholland. All rights reserved.
//

import UIKit

class WelcomePageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    // MARK: - variables
    var orderedViewControllers: [UIViewController] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstViewController")
        let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondViewController")
        let thirdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThirdViewController")
        
        self.orderedViewControllers = [firstVC, secondVC, thirdVC]
        
        
        dataSource = self
        show(index: 0)
    }
    
    // MARK: - Functions
    func show(index: Int) {
        print(#function)
        let vc = orderedViewControllers[index]
        self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }
    
    // MARK: - UIPageViewControllerDataSource protocol
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print(#function)
        let index = orderedViewControllers.lastIndex(of: viewController)!
        if index == 0 {
            return nil
        }
        return orderedViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print(#function)
        let index = orderedViewControllers.lastIndex(of: viewController)!
        if index == orderedViewControllers.count - 1 {
            return nil
        }
        return orderedViewControllers[index + 1]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        print(#function)
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        print(#function)
        guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = orderedViewControllers.lastIndex(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}
